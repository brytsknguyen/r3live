#!/bin/bash

# Compulsary arguments
export EPOC_DIR=$1;
export DATASET_LOCATION=$2;
export ROS_PKG_DIR=$3;
export EXP_NAME=$4;
export CAPTURE_SCREEN=$5;
export LOG_DATA=$6;
export LOG_DUR=$7;

# Optional arguments

ARG_LOOP_EN=${8:-0}
export LOOP_EN=$ARG_LOOP_EN;

ARG_FUSE_VIS=${9:-0}
export FUSE_VIS=$ARG_FUSE_VIS;

ARG_ENABLE_PREINT=${10:-0}
export ENABLE_PREINT=$ARG_ENABLE_PREINT;

ARG_FLOOR_PRIOR=${11:-0}
export USE_FLOOR_PRIOR=$ARG_FLOOR_PRIOR;

ARG_FUSE_UWB=${12:-0}
export FUSE_UWB=$ARG_FUSE_UWB;

ARG_UWB_BIAS=${13:-0}
export UWB_BIAS=$ARG_UWB_BIAS;

ARG_ANC_ID_MAX=${14:--1}
export ANC_ID_MAX=$ARG_ANC_ID_MAX;


# Begin the processing

export BAG_DUR=$(rosbag info $DATASET_LOCATION/${EXP_NAME}.bag | grep 'duration' | sed 's/^.*(//' | sed 's/s)//');
let LOG_DUR=BAG_DUR+10

echo "BAG DURATION:" $BAG_DUR "=> LOG_DUR:" $LOG_DUR;

let ANC_MAX=ANC_ID_MAX+1

export EXP_OUTPUT_DIR=$EPOC_DIR/result_${EXP_NAME}_${ANC_MAX}anc;
if ((FUSE_VIS==1))
then
export EXP_OUTPUT_DIR=${EXP_OUTPUT_DIR}_vis;
fi
echo OUTPUT DIR: $EXP_OUTPUT_DIR;

export EXP_LOG_DIR=/home/$USER/viral_temp/;
mkdir -p $EXP_LOG_DIR/;
if $LOG_DATA
then
export EXP_LOG_DIR=$EXP_OUTPUT_DIR;
fi
echo BA LOG DIR: $EXP_LOG_DIR;

export BAG_FILE=$DATASET_LOCATION/${EXP_NAME}.bag;

mkdir -p $EXP_OUTPUT_DIR/ ;
cp -R $ROS_PKG_DIR/../config $EXP_OUTPUT_DIR;
cp -R $ROS_PKG_DIR/launch $EXP_OUTPUT_DIR;

# Start roscore and register its PID
roscore &
export ROSCORE_PID=$!;

if $CAPTURE_SCREEN
then
echo CAPTURING SCREEN ON;
( sleep 1; \
ffmpeg -video_size 1920x1080 -framerate 5 -f x11grab -i :0.0+1920,0 \
-loglevel quiet -t $LOG_DUR -y $EXP_OUTPUT_DIR/$EXP_NAME.mp4 ) \
& \
else
echo CAPTURING SCREEN OFF;
sleep 1;
fi

if $LOG_DATA
then
echo LOGGING ON;

rosparam dump $EXP_OUTPUT_DIR/allparams.yaml;
( sleep 5; rostopic echo -p --nostr --noarr /viralc_odometry/pred_odom \
> $EXP_OUTPUT_DIR/predict_odom.csv ) \
& \
( sleep 5; rostopic echo -p --nostr --noarr /aft_mapped_to_init \
> $EXP_OUTPUT_DIR/opt_odom.csv ) \
& \
( sleep 5; timeout $LOG_DUR rostopic echo -b $BAG_FILE -p --nostr --noarr /leica/pose/relative \
> $EXP_OUTPUT_DIR/leica_pose.csv ) \
& \
( sleep 5; timeout $LOG_DUR rostopic echo -b $BAG_FILE -p --nostr --noarr /dji_sdk/imu \
> $EXP_OUTPUT_DIR/dji_sdk_imu.csv ) \
& \
( sleep 5; timeout $LOG_DUR rostopic echo -b $BAG_FILE -p --nostr --noarr /imu_vn_100/imu \
> $EXP_OUTPUT_DIR/vn100_imu.csv ) \
& \
( sleep 5; rostopic echo -p --nostr --noarr /viralc_odometry/optimization_status \
> $EXP_OUTPUT_DIR/optimization_status.csv ) \
& \
else
echo LOGGING OFF;
sleep 1;
fi

# Start the process
roslaunch r3live r3live_atv_hall7_ouster.launch \
bag_file:=$BAG_FILE; \

# Kill all nodes that are still running
rosnode kill --all;

# Kill the roscore
kill $ROSCORE_PID;

# Exit the script
exit;