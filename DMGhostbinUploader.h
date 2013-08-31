#import <Foundation/Foundation.h>

@protocol DMGhostbinUploaderDelegate;

@interface DMGhostbinUploader : NSObject <NSURLConnectionDelegate> {
	NSURLConnection                *_connection;
	NSMutableData                  *_responseData;
	BOOL                           _uploading;
	id<DMGhostbinUploaderDelegate> _delegate;
}
@property(nonatomic, assign) id<DMGhostbinUploaderDelegate> delegate;
@property(nonatomic, assign, readonly, getter = isUploading) BOOL uploading;

- (void)beginUploadingText:(NSString *)text language:(NSString *)language expire:(NSTimeInterval)expireInterval;
- (void)cancelUpload;

@end

@protocol DMGhostbinUploaderDelegate <NSObject>

- (void)uploader:(DMGhostbinUploader *)uploader didFinishUploadingWithURL:(NSURL *)URL;
- (void)uploader:(DMGhostbinUploader *)uploader didFailWithError:(NSError *)error;

@end