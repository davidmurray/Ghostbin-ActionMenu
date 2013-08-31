#import "DMGhostbinUploader.h"

@implementation DMGhostbinUploader
@synthesize delegate = _delegate;
@synthesize uploading = _uploading;

- (void)beginUploadingText:(NSString *)text language:(NSString *)language expire:(NSTimeInterval)expireInterval
{
	if (_uploading) {
		return;
	}

	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"https://ghostbin.com/paste/new"]
														   cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
													   timeoutInterval:60.0];
	[request setHTTPMethod:@"POST"];
	[request setHTTPBody:[[NSString stringWithFormat:@"text=%@&lang=%@&expire=%i%s", text, language, (int)expireInterval, (expireInterval == -1 ? "" : "s")] dataUsingEncoding:NSUTF8StringEncoding]];

	_connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
	[_connection release];

	_uploading = YES;
}

- (void)cancelUpload
{
	[_connection cancel];
	_connection = nil;
	_uploading = NO;
}

- (void)dealloc
{
	if (_responseData) {
		[_responseData release];
		_responseData = nil;
	}

	[super dealloc];
}

#pragma mark - NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
	if (_responseData) {
		[_responseData release];
		_responseData = nil;
	}

	_responseData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	[_responseData appendData:data];
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse*)cachedResponse
{
	return nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	// The Ghostbin URL is acquired in connection:willSendRequest:redirectResponse.

	if (_responseData) {
		[_responseData release];
		_responseData = nil;
	}
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	if (error) {
		if ([_delegate respondsToSelector:@selector(uploader:didFailWithError:)]) {
			[_delegate uploader:self didFailWithError:error];
		}
	}

	if (_responseData) {
		[_responseData release];
		_responseData = nil;
	}
}

- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)redirectResponse;
{
	if (redirectResponse) {
		[connection cancel];
		_uploading = NO;

		if ([_delegate respondsToSelector:@selector(uploader:didFinishUploadingWithURL:)]) {
			[_delegate uploader:self didFinishUploadingWithURL:[[[request URL] copy] autorelease]];
		}

		return nil;
	} else {
		return request;
	}
}


@end