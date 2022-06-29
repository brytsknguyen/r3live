#!/usr/bin/env python
from __future__ import print_function

# Python libs
import sys, time

# numpy and scipy
import numpy as np

# OpenCV
import cv2

# Ros libraries
import rospy

# Ros Messages
from sensor_msgs.msg import Image

from cv_bridge import CvBridge, CvBridgeError

import ros_numpy

class image_rotate:

    def __init__(self):
        '''Initialize ros publisher, ros subscriber'''
        # topic where we publish
        self.image_pub = rospy.Publisher("/pylon_camera_node/image_raw_rotated", Image, queue_size = 100)
        self.bridge = CvBridge()

        # subscribed Topic
        self.subscriber = rospy.Subscriber("/pylon_camera_node/image_raw", Image, self.callback, queue_size = 100)

        print("subscribed to /pylon_camera_node/image_raw")


    def callback(self, ros_data):
    
        img = ros_numpy.numpify(ros_data)

        center = (ros_data.width / 2, ros_data.height / 2)
        # rotate the image by 180 degrees
        M = cv2.getRotationMatrix2D(center, 180, 1.0)
        img_rotated = cv2.warpAffine(img, M, (ros_data.width, ros_data.height))

        # #### Create Image and publish ####
        try:
            msg = self.bridge.cv2_to_imgmsg(img_rotated)
            self.image_pub.publish(msg)
        except CvBridgeError as e:
            print(e)   
        
        #self.subscriber.unregister()

def main(args):
    '''Initializes and cleanup ros node'''
    ic = image_rotate()
    rospy.init_node('image_rotate', anonymous=True)
    try:
        rospy.spin()
    except KeyboardInterrupt:
        print("Shutting down ROS Image feature detector module")
    cv2.destroyAllWindows()

if __name__ == '__main__':
    main(sys.argv)