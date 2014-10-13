#!/bin/sh

# FYI, use ffprobe <video_file> to get current encoder info for a video

# transcode/convert

thumb_time_offset=2
thumb_size="320x240" # 320x240, 640x480, etc, WxH

for infile in *.mp4; do
  name_wo_ext="${infile%%\.*}" # removes all exts, use ${infile%\.*} for just the last extension
  out_video="${name_wo_ext}.stream.mp4"
  out_thumbnail="${name_wo_ext}.jpg"
  # these two ffmpeg operations can be done simultaneously, but they are not for clarity and ease
  # plus, the 2nd operation is super quick
  # transcode
  ffmpeg -i $infile -vcodec h264 -movflags faststart -acodec libfdk_aac -f mp4 $out_video
  # create thumbnail, could use $infile or $out_video as src
  ffmpeg -itsoffset -${thumb_time_offset} -i $out_video \
    -vcodec mjpeg -vframes 1 -an -f rawvideo -s ${thumb_size} $out_thumbnail
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
