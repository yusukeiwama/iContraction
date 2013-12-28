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
@property (weak, nonatomic) IBOutlet UILabel *alphaLabel;
@property (weak, nonatomic) IBOutlet UISlider *alphaRadiusSlider;
@property (weak, nonatomic) IBOutlet UISlider *alphaAngleSlider;

- (IBAction)tapAction:(id)sender;
- (IBAction)alphaValueChanged:(id)sender;


@end

@implementation USKViewController {
	int _iteration;
	_Complex double _alpha;
	_Complex double *_currentMapping;
	int _n; // initial number of points
	
	double _scale;
	double _inv;
	CGFloat _xOffset;
	CGFloat _yOffset;
}

@synthesize imageView = _imageView;
@synthesize alphaLabel = _alphaLabel;
@synthesize alphaRadiusSlider = _alphaRadiusSlider;
@synthesize alphaAngleSlider = _alphaAngleSlider;

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	_alpha = 0.5 + sqrt(3) / 6.0 * I;
	
	_n = 3;
	
	_scale = self.view.frame.size.width;
//	_scale = self.view.frame.size.width / 3.0;
	_inv = -1;
	_xOffset = 0.0;
//	_xOffset = self.view.frame.size.width / 3.0;
	_yOffset = self.view.frame.size.height / 2.0;
	
	[self reset];
}

- (void)reset
{
	_Complex double *z0 = calloc(_n, sizeof(_Complex double));
	z0[0] = 0.0 + 0.0 * I;
	z0[1] = 1.0 + 0.0 * I;
	z0[2] = 0.5 + sqrt(12.0) / 12.0 * I;
	printf("z0[0] = %f + %fi\n", creal(z0[0]), cimag(z0[0]));
	printf("z0[1] = %f + %fi\n", creal(z0[1]), cimag(z0[1]));
	printf("z0[2] = %f + %fi\n", creal(z0[2]), cimag(z0[2]));
	
	_iteration = 0;
	
	UIGraphicsBeginImageContextWithOptions((self.imageView.frame.size), YES, 0);
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSetStrokeColorWithColor(context, [[UIColor colorWithWhite:1.0 alpha:1.0] CGColor]);
	CGContextSetLineWidth(context, 1.0);
	
	CGContextMoveToPoint(context, creal(z0[0]) * _scale + _xOffset, cimag(z0[0]) * _scale * _inv + _yOffset);
	for (int i = 1; i < _n; i++) {
		CGContextAddLineToPoint(context, creal(z0[i]) * _scale + _xOffset, cimag(z0[i]) * _scale * _inv + _yOffset);
	}
	CGContextAddLineToPoint(context, creal(z0[0]) * _scale + _xOffset, cimag(z0[0]) * _scale * _inv + _yOffset);
	
	CGContextStrokePath(context);
	self.imageView.image = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	_currentMapping = z0;
}

- (void)drawContraction:(_Complex double *)z
{
	if (_iteration > 13) {
		free(z);
		[self reset];
		return;
	}
	
	_Complex double *zn = calloc(_n * pow(2, (_iteration + 1)), sizeof(_Complex double));
	for (int i = 0; i < pow(2, _iteration); i++) {
		for (int j = 0;  j < _n; j++) {
			zn[_n * i + j] = _alpha * conj(z[_n * i + j]);
//			zn[_n * i + j + _n * (int)(pow(2, _iteration))] = conj(_alpha) * conj(z[_n * i + j]) + _alpha;
			zn[_n * i + j + _n * (int)(pow(2, _iteration))] = cabs(_alpha) * cabs(_alpha) + (1 - cabs(_alpha) * cabs(_alpha)) * conj(z[_n * i + j]);
//			zn[_n * i + j + _n * (int)(pow(2, _iteration))] = (z[_n * i + j] + _alpha) / (1 + _alpha);
		}
	}
	
	UIGraphicsBeginImageContextWithOptions((self.imageView.frame.size), YES, 0);
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSetStrokeColorWithColor(context, [[UIColor colorWithHue:_iteration / 12.0 saturation:1.0 brightness:1.0 alpha:1.0] CGColor]);
	CGContextSetLineWidth(context, 1.0);
	
	for (int i = 0; i < pow(2, _iteration + 1); i ++) {
		CGContextMoveToPoint(context, creal(zn[3 * i]) * _scale + _xOffset, cimag(zn[3 * i]) * _scale * _inv + _yOffset);
		for (int j = 1; j < _n; j++) {
			printf("zn[%d] = %f + %fi\n", _n * i + j, creal(zn[_n * i + j]), cimag(zn[_n * i + j]));
			CGContextAddLineToPoint(context, creal(zn[3 * i + j]) * _scale + _xOffset, cimag(zn[3 * i + j]) * _scale * _inv + _yOffset);
		}
		CGContextAddLineToPoint(context, creal(zn[3 * i]) * _scale + _xOffset, cimag(zn[3 * i]) * _scale * _inv + _yOffset);
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

- (IBAction)alphaValueChanged:(id)sender {
	_alpha = self.alphaRadiusSlider.value * cos(self.alphaRadiusSlider.value) + self.alphaRadiusSlider.value * sin(self.alphaAngleSlider.value) * I;
	self.alphaLabel.text = [NSString stringWithFormat:@"alpha: (radius, angle) = (%.2f, %.2f)", self.alphaRadiusSlider.value, self.alphaAngleSlider.value];
	
	
}
@end
