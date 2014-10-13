#!/bin/sh

# transcode/convert

for f in *.mp4; do
  ffmpeg -i $f -vcodec h264 -movflags faststart -acodec libfdk_aac -f mp4 ${f%\.*}.yt.mp4
done

# for all .mp4s in current dir
#   ffmpeg with input file being the located mp4s with the following output settings
#     These settings are optimzed for youtube streaming
#     -vcodec: video codec of h264
#     -movflags: faststart to make it streamable
#     -acodec: audio codec of aac (non-experimental)
#     - f: output container .mp4
#     and a filename of inputfile w/o extensions + .yt.mp4

# upload to youtube

#$ youtube-upload \
#  --email=myemail@gmail.com --password=mypassword \
#  --title="A.S. Mutter" --description="A.S. Mutter plays Beethoven" \
#  --category=Music --keywords="mutter, beethoven" anne_sophie_mutter.flv
#www.youtube.com/watch?v=pxzZ-fYjeYs

# ruby api sample: https://github.com/youtube/api-samples/tree/master/ruby
