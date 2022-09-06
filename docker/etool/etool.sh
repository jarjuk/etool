#!/bin/bash
APPI="marcus2002/etool"

# error trap
set -e
err_report() {
  echo "$APPI, error on line $1"
}
trap 'err_report $LINENO' ERR

# App directories (sync with Dockerfile)
EMC=/emc
ETOOL_BIN=/etool-bin
EXAMPLE_DIR=/resources

# Data directories (sync with docker run -v option)

ROOT="/etool"
GERBERS_DIR=$ROOT/01-gerber
IMAGES_DIR=$ROOT/01-image
CAM_OUTPUT_DIR=$ROOT/02-ngc
SILK_OUTPUT_DIR=$ROOT/02-silk
PROBED_DIR=$ROOT/03-pgc
# MILLING_DIR=$ROOT/04-cnc

# pcb2gcode options:

CAM_DEFAULT_PARAMS_FILE=$ROOT/pcb2gcode.ini
CAM_CONTROL_TEMPLATE_FILE=$ROOT/pcb2gcode-control.template


LINUXCNC_INI_FILE=$ROOT/linuxcnc/configs/sim.axis/axis_etool.ini
LINUXCNC_TOOL_TABLE_FILE=$ROOT/linuxcnc/configs/sim.axis/sim_mm.tbl
LINUXCNC_RC_FILE=$ROOT/.linuxcncrc

SILK_IMAGE_TYPE=png
SILK_IMAGE_DPI=1200

# ----------
# app constants

# cam control file is gerated using 'CAM_CONTROL_TEMPLATE_FILE'
CAM_CONTROL_FILE=/tmp/pcb2gcode-control.ini


# Facts
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

     # self reflection I know my version
     tag_version() {
         local TAG=$(cat $ETOOL_BIN/VERSION)
         echo $TAG
     }


     # ------------------------------------------------------------------
     # usage - help text

     usage_example() {
         TAG=
         cat <<EOF
         Example usage:

         mkdir \$HOME/.etool             # create working directory

         export ETOOL='docker run --rm --user 1000:1000 -e DISPLAY=unix:0 -v /tmp/.X11-unix:/tmp/.X11-unix -v \$HOME/.etool:/etool marcus2002/etool:$(tag_version)'

         \$ETOOL cleanup                 # clean working directories
         \$ETOOL ls                      # empty directories
         \$ETOOL example gerber soic     # init example 'soic'
         \$ETOOL ls                      # expect to see directory $GERBERS_DIR populated
         \$ETOOL gerber soic             # create gCode for project 'soic'
         \$ETOOL adrill soic             # create gcode for alignment create for project 'soic'
         \$ETOOL simulator               # start linuxcnc for simulating gcode

         The commands can be given as a one-liner. For example, for the command above:

         \$ETOOL cleanup ls example gerber soic ls gerber soic --  adrill soic simulator
         
         Notice! Separator '--' in cam -command signals end of optional parameters
EOF
     }

     version() {
         cat <<EOF
         $APPI:$(cat $ETOOL_BIN/VERSION)
EOF
     }
     
     usage() {
         echo
         EXAMPLES="$(ls $EXAMPLE_DIR/ | grep -e 'gerber$' | sed 's!-gerber!!' | tr '\n' ' ' )"

         
         version
         
         cat <<EOF

         A tool for mapping Gerber/image files to gcode for CNC
         machining and launching linuxcnc -simulator for validating
         CNC execution paths.

         Usage:

         docker DOCKER_OPTS run $APPI CMD_AND_OPTIONS ...

         where CMD_AND_OPTIONS one of follwoing operations:
         o gerber PROJECT [USER] : create gcode for PROJECT Gerber -files into $CAM_OUTPUT_DIR -dir
                                   and $SILK_IMAGE_TYPE image files for laser engraving into $SILK_OUTPUT_DIR -dir.
                                   USER -specific cam parameters replace default paramerters
                                   ($CAM_DEFAULT_PARAMS_FILE, $CAM_CONTROL_TEMPLATE_FILE)
         o adrill PROJECT        : convert PTH -drill file to alignement PTH-ALIGN drill file,
                                   used for two sided boards in $CAM_OUTPUT_DIR -dir
         o simulator             : start 'linuxcnc'

         or image cam operation:
         o image IMAGE           : convert IMAGE in $IMAGES_DIR to gcode into $CAM_OUTPUT_DIR 

         or one of data management utilities:
         o ls                    : list data files in $ROOT -data directories
         o cleanup               : remove files from $ROOT -data directories
                                   $GERBERS_DIR, $IMAGES_DIR, $CAM_OUTPUT_DIR, and $SILK_OUTPUT_DIR
         o example TYPE PROJECT  : copy example PROJECT of TYPE input directory
                                   TYPE is 'gerber' or 'image', with respective input direcotories
                                   01-gerber and 01-image

         or one of miscallaneous commands:
         o --help                : this help text
         o usage                 : workflow example (w. example of multiple commands on one line)
         o gerber-help           : help on pcb2gcode options to put into
                                   $CAM_DEFAULT_PARAMS_FILE -file and open image explaining
                                   dimension options
         o releases              : output RELEASES document
         o Dockerfile            : show Dockerfile used

         and DOCKER_OPTS options for 'docker run' -command, particularly
         o --rm                             : cleanup after Docker finished
         o --user \$(id -u):\$(id -g)         : user credentials (instead of root)
         o -e DISPLAY=unix:0                : allow Docker to open X11 apps
         o -v /tmp/.X11-unix:/tmp/.X11-unix : allow Docker to open X11 apps
         o -v HOSTD:/etool                  : data directory HOSTD (must exist,
                                              owned by --user), structure is initialized
         
EOF

       # undocumented
       # - probe PAR*      : run 'pcbGcodeZprobing' with parameters PAR*
       # - exe WHAT        : WHAT $*, break"
     }

     die() { echo "$*" 1>&2 ; exit 1; }

     # Ensure directrory $1 exists
     mkdir_if_not_exist() {
       local dir=$1; shift
       # echo Creatig dir $dir
       [ ! -d $dir ] && mkdir -p $dir && echo Directory $dir created || echo Directory $dir exits - not modified
     }

     # Ensure file $1 exist, defaults to $2
     mkfile_if_not_exist() {
       local file=$1; shift
       local content="$1"; shift
       # echo mkfile_if_not_exist: content=$content
       [ ! -f $file ] && cp $content $file && echo File $file created || echo File $file exits - not modified
     }

     addProbe() {
         # Add probe support to 'file'
         # 
         # Output: probeFile and noPropeFile
         local file=$1
         local ext="${file##*.}"
         local stem="${file%.*}"
         
         local noProbeFile=$stem-noProbe.$ext
         local probeFile=$stem-Probe.$ext
         local probeAdder=$ETOOL_BIN/pcbGcodeZprobing.py
         
         if [ -f $ROOT/pcbGcodeZprobing.py ]; then
             # override with user code
             probeAdder=$ROOT/pcbGcodeZprobing.py
         fi
         
         mv $file $noProbeFile
         python $probeAdder $noProbeFile > $probeFile
         echo "Gcode with probe support:       $probeFile"
         echo "Gcode without probe (original): $noProbeFile"
     }

     silkImage() {
         # extract image from gerber, adjust DPI (because gerbv seems to leave out DPI paramter)
         # background silks are un-mirrored
         local silk_stem=$1; shift
         local flip=$1; shift
         echo "Convert Gerber  $GERBERS_DIR/${silk_stem}.gbr to $SILK_IMAGE_TYPE -image $SILK_OUTPUT_DIR/${silk_stem}.$SILK_IMAGE_TYPE"
         if [ ! -f $GERBERS_DIR/${silk_stem}.gbr ]; then
             echo "--> No such file $GERBERS_DIR/${silk_stem}.gbr - no conversion"
         fi
         gerbv  -x $SILK_IMAGE_TYPE --dpi=$SILK_IMAGE_DPI -o $SILK_OUTPUT_DIR/${silk_stem}-tmp.$SILK_IMAGE_TYPE $GERBERS_DIR/${silk_stem}.gbr
         if [ ! -z "$flip" ]; then
             # back side silp mirrored in gerber -> flip/flop 
             convert $flip -units PixelsPerInch $SILK_OUTPUT_DIR/${silk_stem}-tmp.$SILK_IMAGE_TYPE -density $SILK_IMAGE_DPI $SILK_OUTPUT_DIR/${silk_stem}-tmp2.$SILK_IMAGE_TYPE
             mv $SILK_OUTPUT_DIR/${silk_stem}-tmp2.$SILK_IMAGE_TYPE $SILK_OUTPUT_DIR/${silk_stem}-tmp.$SILK_IMAGE_TYPE
         fi
         convert -units PixelsPerInch $SILK_OUTPUT_DIR/${silk_stem}-tmp.$SILK_IMAGE_TYPE -density $SILK_IMAGE_DPI $SILK_OUTPUT_DIR/${silk_stem}.$SILK_IMAGE_TYPE
         rm -f $SILK_OUTPUT_DIR/${silk_stem}-tmp.$SILK_IMAGE_TYPE
     }

     # ------------------------------------------------------------------
     # Init context - only if not exist
     INIT_DONE=0
     initApp() {
         # only once
         if [ $INIT_DONE != 0 ]; then return; fi
         mkdir_if_not_exist $GERBERS_DIR
         mkdir_if_not_exist $IMAGES_DIR
         mkdir_if_not_exist $CAM_OUTPUT_DIR
         mkdir_if_not_exist $SILK_OUTPUT_DIR
         # mkdir_if_not_exist $PROBED_DIR
         # mkdir_if_not_exist $MILLING_DIR
         mkdir_if_not_exist $ROOT/linuxcnc/configs/sim.axis

         # init all config files
         for f in /etool-cnf/*; do
             mkfile_if_not_exist $ROOT/$(basename $f)  $f 
         done 
         # Copy default config files respective places
         # mkfile_if_not_exist $CAM_DEFAULT_PARAMS_FILE $ETOOL_BIN/$(basename $CAM_DEFAULT_PARAMS_FILE)
         # mkfile_if_not_exist $CAM_CONTROL_TEMPLATE_FILE $ETOOL_BIN/$(basename $CAM_CONTROL_TEMPLATE_FILE)
         mkfile_if_not_exist $LINUXCNC_INI_FILE $ETOOL_BIN/$(basename $LINUXCNC_INI_FILE)
         mkfile_if_not_exist $LINUXCNC_TOOL_TABLE_FILE $ETOOL_BIN/$(basename $LINUXCNC_TOOL_TABLE_FILE)


         mkfile_if_not_exist $LINUXCNC_RC_FILE $ETOOL_BIN/$(basename $LINUXCNC_RC_FILE)
         INIT_DONE=1
     }


     # ------------------------------------------------------------------
     # Main loop

     while :
     do

         if [  $# -lt 1 ]; then
            break
         fi

         CMD=$1
         shift

         case "$CMD" in
             ls)
               initApp
               ls -l $GERBERS_DIR $IMAGES_DIR $CAM_OUTPUT_DIR $SILK_OUTPUT_DIR  # $PROBED_DIR
               ;;
             --)
               shift
               ;;
             pcb2gcode)
               initApp
               pars=()
               while [ $# -ge 1 ]; do
                   if [ "$1" = '--' ]; then break; fi
                   pars+=" $1"; shift
               done
               echo RUN: pcb2gcode ${pars[@]}
               pcb2gcode ${pars[@]}
               ;;
             cam)
               die 'No such command "cam", use "gerber" instead'
               ;;
             image)
                 initApp
                 if [ $# -lt 1 ]; then
                   die "image IMAGE: No IMAGE given"
                 fi
                 IMAGE=$1; shift
                 [ -f $IMAGES_DIR/$IMAGE ] || die "Image $IMAGE not found $IMAGES_DIR- use ls -command to check images"
                 
                 # filename sans extension
                 OUTPUT="${IMAGE%.*}.ngc"

                 # using conda here (could not find pillow/Image otherwise)
                 eval "$(conda shell.bash hook)"
                 # conda run -n ebench
                 conda activate image-2-gcode

                 # Start 'image-to-gcode' in linuxcnc
                 . $EMC/scripts/rip-environment
                 python $EMC/bin/image-to-gcode $IMAGES_DIR/$IMAGE >  $CAM_OUTPUT_DIR/$OUTPUT
                 # cancel -> exit status != 0 -> TRAP -> this line not reached
                 addProbe $CAM_OUTPUT_DIR/$OUTPUT

                 ls $CAM_OUTPUT_DIR/*
                 ;;
             gerber)
               initApp
               if [ $# -lt 1 ]; then
                   die "gerber PROJECT [USER]: No PROJECT given"
               fi
               PROJECT=$1; shift

               # default values
               CONTROL_TEMPLATE=$CAM_CONTROL_TEMPLATE_FILE
               PARAMS=$CAM_DEFAULT_PARAMS_FILE

               # optional USER
               if [ $# -ge 1 ]; then
                   if [ "$1" != '--' ]; then
                       PARAMS=$ROOT/pcb2gcode-${1}.ini
                       CONTROL_TEMPLATE=$ROOT/pcb2gcode-control-${1}.template
                       # files must exist
                       [ -f $PARAMS ] || die "Cam parameter file $PARAMS not exist - invalid USER parameter '$1'  (try one of: $(ls $ROOT/pcb2gcode-*.ini | sed -E 's!.*/pcb2gcode-(.*)\.ini!\1!'))"
                       [ -f $CONTROL_TEMPLATE ] || die "Control template file $CONTROL_TEMPLATE does not exist - invalid USER parameter '$1'"
                   fi
                   shift
               fi

               # read template, evaluate in two passes below
               read -r -d '' TMPL <$CONTROL_TEMPLATE || true
               echo pcb2gcode using configuration files $CONTROL_TEMPLATE, $PARAMS

               # Ref env context promises in 'pcb2gcode-control.template'
               
               # PASS1 - comment out PASS2 and run 'pcb2gcode'
               PASS1=""
               PASS2="# "
               echo "${TMPL@P}" > $CAM_CONTROL_FILE
               pcb2gcode --config $CAM_CONTROL_FILE,$PARAMS

               # PASS1 - comment out PASS1 and return 'pcb2gcode'
               PASS1="# "
               PASS2=""
               echo "${TMPL@P}" > $CAM_CONTROL_FILE
               pcb2gcode --config $CAM_CONTROL_FILE,$PARAMS

               # producde silḱ
               # F_SILK=${PROJECT}-F_SilkS
               # B_SILK=${PROJECT}-B_SilkS
               silkImage ${PROJECT}-F_SilkS ""
               silkImage ${PROJECT}-F_Silkscreen ""
               silkImage ${PROJECT}-B_SilkS "-flop"
               silkImage ${PROJECT}-B_Silkscreen "-flop"
               silkImage ${PROJECT}-User_1 ""
               silkImage ${PROJECT}-User_2 "-flop"
               ;;
             adrill)  # alignment drilling
                 if [ $# -lt 1 ]; then
                     die "adrill PROJECT: No PROJECT given"
                 fi
                 PROJECT=$1; shift
                 PTH_PATH=$CAM_OUTPUT_DIR/${PROJECT}-PTH.ngc
                 if [ ! -f $PTH_PATH ]; then
                     die "adrill PROJECT: No PTH_FILE found $PTH_PATH"
                 fi
                 $ETOOL_BIN/adrill.sh $PTH_PATH
                 ;; 
             cam-help|gerber-help)
               pcb2gcode --help
               # Show image explaining cam dimensions
               inkscape /resources/pcb2gcode/options.svg
               ;;
             image-help)
               firefox /resources/doc/Image-to-gcode.html
               ;;
             probe)
                 initApp
                 INFILE=$1;shift
                 python /pcbGcodeZprobing/pcbGcodeZprobing.py $CAM_OUTPUT_DIR/$INFILE > $PROBED_DIR/$INFILE
                 ;;
             dockerfile|Dockerfile)
                 cat /etool-bin/Dockerfile
                 break
                 ;;
             simulator)
               initApp
               pars=()
               while [ $# -ge 1 ]; do
                   if [ "$1" = '--' ]; then break; fi
                   pars+=" $1"; shift
               done
               echo RUN: linuxcnc ${pars[@]}
               . $EMC/scripts/rip-environment
               # $EMC/scripts/linuxcnc
               linuxcnc ${pars[@]}
               ;;
             none)
               ;;
             releases)
               initApp
               cat $SCRIPT_DIR/RELEASES
               break
               ;;
             -?|--?|--help)
               usage
               break
               ;;
             usage)
               usage
               usage_example
               ;;
             --version)
                 version
                 ;;
             example)
               if [ $# -lt 1 ]; then
                   die "usage: example TYPE PROJECT"
               fi
               TYPE=$1; shift
               case $TYPE in
                   gerber|image)
                   ;;
                   *)
                       die "example TYPE PROJECT: $TYPE not one of image,gerber"
                   ;;
               esac
               EXAMPLE=$1; shift
               initApp
               # Expect to find /resources/EXAMPLE-gerber
               if [ ! -d $EXAMPLE_DIR/$EXAMPLE-$TYPE ]; then
                   # List /resource/xxxx-gerber
                   echo No such example $EXAMPLE - valid examples $(ls -1 $EXAMPLE_DIR/ | grep -e "${TYPE}$" | sed "s!-$TYPE!!")
                   exit 1
               fi
               cp $EXAMPLE_DIR/${EXAMPLE}-$TYPE/* $ROOT/01-$TYPE
               ls $ROOT/01-$TYPE
               ;;
             cleanup)
               initApp
               rm -f $GERBERS_DIR/* $IMAGES_DIR/* $CAM_OUTPUT_DIR/*  $SILK_OUTPUT_DIR/* # $PROBED_DIR/*
               ls $GERBERS_DIR $IMAGES_DIR
               ;;
             exe)
               initApp
               # Hidden command
               CMD=$1; shift
               pars=()
               while [ $# -ge 1 ]; do
                   if [ "$1" = '--' ]; then shift; break; fi
                   pars+=" $1"; shift
               done
               eval $CMD ${pars[@]}
               ;;
             *)
               echo Unknown command $CMD
               usage
               echo ""
               exit 1
               ;;
         esac
     done
     exit 0
