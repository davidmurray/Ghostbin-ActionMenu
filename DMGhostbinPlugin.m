#import "DMGhostbinPlugin.h"
#import "DMGhostbinUploader.h"

static DMGhostbinUploader *ghostbinUploader;

static void DMShowHUDWithText(NSString *text, BOOL success);
static void DMShowHUDWithText(NSString *text, BOOL success)
{
	UIProgressHUD *HUD = [[[UIProgressHUD alloc] init] autorelease];
	[HUD showInView:[[UIApplication sharedApplication] keyWindow]];

	if (!success) {
		// This is a hack.
		[[HUD _progressIndicator] setHidden:YES];
	} else {
		[HUD done];
	}

	[HUD setText:text];
	[HUD performSelector:@selector(hide) withObject:nil afterDelay:1.0f];
}

@implementation UIResponder (DMGhostbinPlugin)

+ (void)load
{
	[[UIMenuController sharedMenuController] registerAction:@selector(uploadToGhostbin) title:@"Ghostbin" canPerform:@selector(canUploadToGhostbin)];
}

- (BOOL)canUploadToGhostbin
{
	return ([[self selectedTextualRepresentation] length] > 0);
}

- (void)uploadToGhostbin
{
	if (ghostbinUploader) {
		[ghostbinUploader cancelUpload];
		[ghostbinUploader release];
		ghostbinUploader = nil;
	}

	NSString *escapedText = [(NSString *)CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)[self selectedTextualRepresentation], NULL, (CFStringRef)@"!*'();:@&=+$,/?%#[]", kCFStringEncodingUTF8) autorelease];

	ghostbinUploader = [[DMGhostbinUploader alloc] init];
	[ghostbinUploader setDelegate:(id<DMGhostbinUploaderDelegate>)self];
	[ghostbinUploader beginUploadingText:escapedText language:@"text" expire:-1];
}

#pragma mark - DMGhostbinUploaderDelegate

- (void)uploader:(DMGhostbinUploader *)uploader didFinishUploadingWithURL:(NSURL *)URL
{
	DMShowHUDWithText(@"Copied", YES);

	[[UIPasteboard generalPasteboard] setString:[URL absoluteString]];

	[ghostbinUploader release];
	ghostbinUploader = nil;
}

- (void)uploader:(DMGhostbinUploader *)uploader didFailWithError:(NSError *)error
{
	DMShowHUDWithText(@"Failed", NO);

	NSLog(@"[%s]:[%s] Error while uploading: %@", __FILE__, __FUNCTION__, error);

	[ghostbinUploader release];
	ghostbinUploader = nil;
}

@end
