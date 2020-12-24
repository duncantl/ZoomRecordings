if(FALSE) {
    # In the NAMESPACE now that this is a package.
library(RCurl)
library(XML)
library(RJSONIO)
library(Rcompression)
}


getCon =
function(token = NA, ..., zcookie = readLines("cookie", warn = FALSE)[1])
{

    hdr = c(Accept = "application/json;*/*;q=0.01",
            Origin = "https://ucdavis.zoom.us",
            `Accept-Encoding` = "gzip, deflate, br",
            `Accept-Language` = "en-US,en;q=0.5")

    if(!is.na(token))
        hdr['ZOOM-CSRFTOKEN'] = token
    
    con = getCurlHandle(cookie = zcookie, verbose = TRUE, followlocation = TRUE,
                        useragent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:83.0) Gecko/20100101 Firefox/83.0",
                        referer = "https://ucdavis.zoom.us/recording",
                        httpheader = hdr,
                        ...)
}


getRecInfo =
function(dates = c("", "12/18/2020"), con = getCon(), numPages = NA, h = "https://ucdavis.zoom.us/recording/host_list")    
{

    pageNum = 1L
    pages = list()
    
    # XXX Adapt to find the correct number of pages.
    while(TRUE) {
        if(!is.na(numPages) && pageNum > numPages)
            break

        tmp = fromJSON(postForm(h, from=dates[1], to = dates[2], p = pageNum, curl = con, style = "post"))
        if(!tmp$status || length(tmp$result$recordings) == 0)
            break
        
        pages[[pageNum]] = tmp 
        pageNum = pageNum + 1L
    }

    recs = lapply(pages, function(x) x$result$recordings)
    infoAsDF(recs)
#    structure(unlist(, recursive = FALSE), class = "ZoomRecordingInfo")
}

infoAsDF =
function(x)    
{  
    tt = table(unlist(lapply(x, names)))
    m = names(tt)[ tt < length(x) ]
    ans = do.call(rbind, lapply(x, function(x) {
                              v = as.data.frame(x, stringsAsFactors = FALSE)
                              w = !(m %in% names(v))
                              if(any(w))
                                 v[m[w]] = NA
                              v
                          }))

    v = c("meetingStartTime", "createTime", "modifyTime")
    ans[v] = lapply(ans[v], function(x) structure(x/1000, class = c("POSIXt", "POSIXct")))
    ans
}

getMeetingIds =
function(recs)
{
    sapply(recs, `[[`, "meetingId")
}


getMeetingTime =
function(recs)
{
  structure( sapply(recs, `[[`, "meetingStartTime")/1000, class = c("POSIXt", "POSIXct"))
}




downloadVideo =
function(mid, con = getCon(..., timeout = timeout), ..., timeout = 600)
{
    r1 = getForm("https://ucdavis.zoom.us/recording/detail", meeting_id = mid, curl = con, binary = TRUE)
    r1 = gunzip(r1)
    doc = htmlParse(r1)
    id = getNodeSet(doc, "//a[@role='button' and @aria-label='Download']/@data-id")
    uid = sprintf("https://ucdavis.zoom.us/rec/sdownload/%s", id[[1]])

    tmp = getURLContent(uid, verbose = TRUE, curl = con, binary = TRUE)
}


