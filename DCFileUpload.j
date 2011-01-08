@import <AppKit/CPPanel.j>

/*

DCFileUploadDelegate protocol
- (void)fileUploadDidBegin:(DCFileUpload)theController;
- (void)fileUploadProgressDidChange:(DCFileUpload)theController;
- (void)fileUploadDidEnd:(DCFileUpload)theController;

*/

@implementation DCFileUpload : CPObject {
	CPString name @accessors;
	float progress @accessors;
	id delegate @accessors;
	CPURL uploadURL @accessors;

	id file;
	CPURLConnection uploadConnection;
	CPURLRequest uploadRequest;
	BOOL isUploading;
}

- (id)initWithFile:(id)theFile {
	self = [super init];
	file = theFile;
	progress = 0.0;
	isUploading = NO;
	return self;
}

- (void)begin {
    uploadRequest = [CPURLRequest requestWithURL:uploadURL];
    [uploadRequest setHTTPMethod:"POST"];
    [uploadRequest setHTTPBody:file];
    [uploadRequest setValue:file.fileName forHTTPHeaderField:"X-File-Name"];
    [uploadRequest setValue:file.fileSize forHTTPHeaderField:"X-File-Size"];
    uploadConnection = [CPURLConnection connectionWithRequest:uploadRequest delegate:self];
    var fileUpload = uploadConnection._HTTPRequest._nativeRequest.upload;
    if (fileUpload)
    {
        fileUpload.addEventListener("progress", function(event) {
    		if (event.lengthComputable) {
    			[self setProgress:event.loaded / event.total];
    			[self fileUploadProgressDidChange];
    		}
    	}, false);

    	fileUpload.addEventListener("load", function(event) {
    		[self fileUploadDidEnd];
    	}, false);

    	fileUpload.addEventListener("error", function(evt) {
    		CPLog("error: " + evt.code);
    	}, false);
    }
    [self fileUploadDidBegin];
}

- (void)fileUploadDidBegin {
	isUploading = YES;
	if ([delegate respondsToSelector:@selector(fileUploadDidBegin:)]) {
		[delegate fileUploadDidBegin:self];
	}
}

- (void)fileUploadProgressDidChange {
	isUploading = YES;
	if ([delegate respondsToSelector:@selector(fileUploadProgressDidChange:)]) {
		[delegate fileUploadProgressDidChange:self];
	}
}

- (void)fileUploadDidEnd{
	isUploading = NO;
	if ([delegate respondsToSelector:@selector(fileUploadDidEnd:)])
		[delegate fileUploadDidEnd:self];
}

- (void)connection:(CPURLConnection)aConnection didReceiveResponse:(CPURLResponse)aResponse
{
    if ([delegate respondsToSelector:@selector(fileUpload:didReceiveResponse:)])
		[delegate fileUpload:self didReceiveResponse:aResponse];
}

- (void)connection:(CPURLConnection)aConnection didReceiveData:(CPString)aString
{
    if ([delegate respondsToSelector:@selector(fileUpload:didReceiveData:)])
		[delegate fileUpload:self didReceiveData:aString];
}

- (BOOL)isUploading {
	return isUploading;
}

- (void)cancel {
	isUploading = NO;
    [fileUploadConnection cancel];
}

@end
