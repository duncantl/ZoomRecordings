
This allows one to programmatically get meta-data about the recordings
in your zoom account and to programmatically download them.
It appears that some Zoom accounts may have an option to download  recordings in bulk, but mine
does not and I needed to download the recordings from my course (lectures and office hours).

It works, but no frills - yet!


# Usage

First fetch the cookie from the Web browser and save it in the file named "cookie" in your working
directory.
You can do this via the Network tab in the browser's developer tools.
Alternatively, you can fetch it from the Web browser's (SQLite3) database using the RBrowserCookies package.


We first get the meta-data about the recordings with `getRecInfo()`:
```r
library(ZoomRecordings)

info = getRecInfo()
```
This returns a data.frame.

We access the meetingId column with the getMeetingIds() function - 
```r
mids = getMeetingIds(info)
```

Now wecheck we can download one video directly and write it to a file:
```r
tmp = downloadVideo(mids[1])
writeRawToFile(tmp, info[[1]]$meetingStartTimeStr)
```


Now we download all of them and save to them to a different directory
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
