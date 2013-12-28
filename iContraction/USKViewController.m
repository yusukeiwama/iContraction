//
//  USKViewController.m
//  iContraction
//
//  Created by Yusuke Iwama on 12/28/13.
//  Copyright (c) 2013 University of Tsukuba. All rights reserved.
//

#import "USKViewController.h"
#include <complex.h>

@interface USKViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
- (IBAction)tapAction:(id)sender;

@end

@implementation USKViewController {
	int _iteration;
	_Complex double _alpha;
	_Complex double *_currentMapping;
	
	double _scale;
	double _inv;
	CGFloat _yOffset;
}

@synthesize imageView = _imageView;

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	_alpha = 0.5 + sqrt(3) / 6.0 * I;
	
	_Complex double *z0 = calloc(3, sizeof(_Complex double));
	z0[0] = 0.0 + 0.0 * I;
	z0[1] = 1.0 + 0.0 * I;
	z0[2] = 0.5 + sqrt(12.0) / 12.0 * I;
	printf("z0[0] = %f + %fi\n", creal(z0[0]), cimag(z0[0]));
	printf("z0[1] = %f + %fi\n", creal(z0[1]), cimag(z0[1]));
	printf("z0[2] = %f + %fi\n", creal(z0[2]), cimag(z0[2]));

	
	_scale = self.view.frame.size.width;
	_inv = -1;
	_yOffset = self.view.frame.size.height / 2.0;
	
	_iteration = 0;
	
	UIGraphicsBeginImageContextWithOptions((self.imageView.frame.size), YES, 0);
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSetStrokeColorWithColor(context, [[UIColor colorWithWhite:1.0 alpha:1.0] CGColor]);
	CGContextSetLineWidth(context, 1.0);
	
	CGContextMoveToPoint(context, creal(z0[0]) * _scale, cimag(z0[0]) * _scale * _inv + _yOffset);
	CGContextAddLineToPoint(context, creal(z0[1]) * _scale, cimag(z0[1]) * _scale * _inv + _yOffset);
	CGContextAddLineToPoint(context, creal(z0[2]) * _scale, cimag(z0[2]) * _scale * _inv + _yOffset);
	CGContextAddLineToPoint(context, creal(z0[0]) * _scale, cimag(z0[0]) * _scale * _inv + _yOffset);
	
	CGContextStrokePath(context);
	self.imageView.image = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	_currentMapping = z0;
}

- (void)drawContraction:(_Complex double *)z
{
	_Complex double *zn = calloc(3 * pow(2, (_iteration + 1)), sizeof(_Complex double));
	for (int i = 0; i < pow(2, _iteration); i++) {
		for (int j = 0;  j < 3; j++) {
			zn[3 * i + j] = _alpha * conj(z[3 * i + j]);
			zn[3 * i + j + 3 * (int)(pow(2, _iteration))] = conj(_alpha) * conj(z[3 * i + j]) + _alpha;
//			zn[3 * i + j + 3 * (int)(pow(2, _iteration))] = cabs(_alpha) * cabs(_alpha) + (1 - cabs(_alpha) * cabs(_alpha)) * conj(z[3 * i + j]);
//			zn[3 * i + j + 3 * (int)(pow(2, _iteration))] = (z[3 * i + j] + _alpha) / (1 + _alpha);
		}
	}
	
	UIGraphicsBeginImageContextWithOptions((self.imageView.frame.size), YES, 0);
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSetStrokeColorWithColor(context, [[UIColor colorWithWhite:1.0 alpha:1.0] CGColor]);
	CGContextSetLineWidth(context, 1.0);
	
	for (int i = 0; i < 3 * pow(2, _iteration + 1); i += 3) {
		printf("zn[%d] = %f + %fi\n", i, creal(zn[i]), cimag(zn[i]));
		printf("zn[%d] = %f + %fi\n", i+1, creal(zn[i+1]), cimag(zn[i+1]));
		printf("zn[%d] = %f + %fi\n", i+2, creal(zn[i+2]), cimag(zn[i+2]));
		CGContextMoveToPoint(context, creal(zn[i]) * _scale, cimag(zn[i]) * _scale * _inv + _yOffset);
		CGContextAddLineToPoint(context, creal(zn[i + 1]) * _scale, cimag(zn[i + 1]) * _scale * _inv + _yOffset);
		CGContextAddLineToPoint(context, creal(zn[i + 2]) * _scale, cimag(zn[i + 2]) * _scale * _inv + _yOffset);
		CGContextAddLineToPoint(context, creal(zn[i]) * _scale, cimag(zn[i]) * _scale * _inv + _yOffset);
	}
		
	CGContextStrokePath(context);
	self.imageView.image = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	_currentMapping = zn;
	free(z);
	
	_iteration++;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)tapAction:(id)sender {
	[self drawContraction:_currentMapping];
}
@end
