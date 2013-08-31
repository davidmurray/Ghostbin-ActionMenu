#import "DMGhostbinPlugin.h"
#import "DMGhostbinUploader.h"

static DMGhostbinUploader *ghostbinUploader;

@implementation UIResponder (DMGhostbinPlugin)

+ (void)load
{
	[[UIMenuController sharedMenuController] registerAction:@selector(uploadToGhostbin) title:@"Ghostbin" canPerform:@selector(canUploadToGhostbin)];
}

- (BOOL)canUploadToGhostbin
{
	return ([[self selectedTextualRepresentation] length] != 0);
}

- (void)uploadToGhostbin
{
	if (ghostbinUploader) {
		[ghostbinUploader cancelUpload];
		ghostbinUploader = nil;
	}

	ghostbinUploader = [[DMGhostbinUploader alloc] init];
	[ghostbinUploader setDelegate:(id<DMGhostbinUploaderDelegate>)self];
	[ghostbinUploader beginUploadingText:[self selectedTextualRepresentation] language:@"text" expire:-1];
}

#pragma mark - DMGhostbinUploaderDelegate

- (void)uploader:(DMGhostbinUploader *)uploader didFinishUploadingWithURL:(NSURL *)URL
{
	UIProgressHUD *HUD = [[[UIProgressHUD alloc] init] autorelease];
	[HUD showInView:[[UIApplication sharedApplication] keyWindow]];
	[HUD setText:@"Copied"];
	[HUD done];
	[HUD performSelector:@selector(hide) withObject:nil afterDelay:1.0f];

	[[UIPasteboard generalPasteboard] setString:[URL absoluteString]];

	[ghostbinUploader release];
	ghostbinUploader = nil;
}

- (void)uploader:(DMGhostbinUploader *)uploader didFailWithError:(NSError *)error
{
	if (error) {
		NSLog(@"[%s]:[%s] Error while uploading: %@", error, __FILE__, __FUNCTION__);
	}

	[ghostbinUploader release];
	ghostbinUploader = nil;
}

@end
