#!/bin/bash

cd dump

ffmpeg -f image2 -r 4 -i %08d.png -pix_fmt yuv420p -y dump.mp4

cd ..