
This allows one to programmatically get meta-data about the recordings
in your zoom account and to programmatically download them.
It appears that some Zoom accounts may have an option to download  recordings in bulk, but mine
does not and I needed to download the recordings from my course (lectures and office hours).

It works, but no frills - yet!


# Usage

```r
library(ZoomRecordings)

info = getRecInfo()
```

```r
mids = getMeetingIds(info)
```

Check we can download one video directly.
```r
tmp = downloadVideo(mids[1])
writeRawToFile(tmp, info[[1]]$meetingStartTimeStr)
```


Now we download all of them
```r
TargetDirectory = "/Volumes/T5/Sta141B/ZoomRecordings"
filenames = format(getMeetingTime(info), "%d_%b_%Y_%H:%M.mpa")
status = invisible(mapply(function(mid, file) {
                    message(mid, " to ", file)
                    tmp = downloadVideo(mid)
                    try( Gradhub::savePDF(tmp, file))
                },  mids, file.path(TargetDirectory, filenames)))
```



## Notes

+ I added a long timeout (10 minutes) as I was running this through a VPN and it was slow.  You
  could probably have a shorter timeout.
  
+ We can extend this to get the 
   + chat
   + audio
   + transcript
   + analytics
