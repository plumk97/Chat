//
//  MQBrowserPhoto.m
//  Chat
//
//  Created by 货道网 on 15/5/21.
//  Copyright (c) 2015年 李铁柱. All rights reserved.
//

#import "MQBrowserPhoto.h"
#import "UIKit+AFNetworking.h"
@interface Photo : UIScrollView
<UIScrollViewDelegate>
{
    UIImageView * _imageView;
    BOOL isScale;
    
    BOOL isDownload;
}

@property (nonatomic, strong) Message * message;

- (void)downloadImage;

- (void)showAnimation:(UIView *)superView OriginFrame:(CGRect)originFrame;

@end

@implementation Photo

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

        self.delegate = self;
        
        self.zoomScale = 1.0f;
        self.minimumZoomScale = 0.5f;
        self.maximumZoomScale = 3.0f;;

        _imageView = [[UIImageView alloc] init];
        [self addSubview:_imageView];
    }
    return self;
}

/**
 *  缩放指定位置
 *
 *  @param point <#point description#>
 */
- (void)zoomToPoint:(CGPoint)point
{
    if (!isScale) {
        [self zoomToRect:CGRectMake(point.x - 10, point.y - 10, 20, 20) animated:YES];
        isScale = YES;
    } else {
        [self setZoomScale:1.0f animated:YES];
        isScale = NO;
    }
}

/**
 *  复位缩放
 */
- (void)reductionZoom
{
    [self setZoomScale:1.0f animated:YES];
    isScale = NO;
}

- (void)setMessage:(Message *)message
{
    _message = message;
    _imageView.image = _message.image;
    [self initImageViewFrame];
}

/**
 *  下载图片
 */
- (void)downloadImage
{
    if (isDownload) {
        return;
    }
    if (!_imageView.image) {
        _imageView.image = self.message.image;
    }
    
    UIImage * image = nil;
    image = [UIImage imageWithData:[MQChatUtil getDataFromLocationFileName:[MQChatUtil createFileName:self.message.time] Directory:DIRECTORY_IMAGE]];
    if (image) {
        _imageView.image = image;
        [self initImageViewFrame];
        isDownload = YES;
        return;
    }
    
    NSString * url = [[NSString alloc] initWithFormat:@"%@%@",RQHost,_message.remotePath];
    __block typeof(self)  weakSelf = self;
    [_imageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]] placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        
        [weakSelf->_imageView setImage:image];
        

        weakSelf.message.localPath = [MQChatUtil saveDataToLocationFileName:[MQChatUtil createFileName:weakSelf.message.time] Directory:DIRECTORY_IMAGE Data:UIImageJPEGRepresentation(image, 1)];
        [[MQChatManager sharedInstance].managedObjectContext save:nil];
        [weakSelf initImageViewFrame];
        isDownload = YES;
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        
    }];
}

/**
 *  初始化 imageViewFrame
 */
- (void)initImageViewFrame
{
    if (!_imageView.image) {
        return;
    }
    CGSize size = _imageView.image.size;
    CGFloat ratio = MIN(self.frame.size.width / size.width, self.frame.size.height / size.height);
//    if (size.width > self.frame.size.width) {
        size.width *= ratio;
//    }
//    if (size.height > self.frame.size.height) {
        size.height *= ratio;
//    }

    _imageView.bounds = CGRectMake(0, 0, size.width, size.height);
    _imageView.center = CGPointMake(self.frame.size.width / 2.0f, self.frame.size.height / 2.0f);
}

/**
 *  显示起始动画
 *
 *  @param superView   父视图
 *  @param originFrame 起始位置
 */
- (void)showAnimation:(UIView *)superView OriginFrame:(CGRect)originFrame
{
    self.backgroundColor = [UIColor clearColor];
    _imageView.frame = originFrame;
    [UIView animateWithDuration:0.25 animations:^{
        [self initImageViewFrame];
        self.backgroundColor = [UIColor blackColor];
    }];
}

// MARK: - Scroll Delegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return _imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    
    scrollView.contentSize = CGSizeMake(MAX(self.frame.size.width, _imageView.frame.size.width), MAX(self.frame.size.height, _imageView.frame.size.height));
    
    CGSize contentSize = scrollView.contentSize;
    contentSize.width = contentSize.width < self.frame.size.width ? self.frame.size.width : contentSize.width;
    contentSize.height = contentSize.height < self.frame.size.height ? self.frame.size.height : contentSize.height;
    
    _imageView.center = CGPointMake(contentSize.width / 2.0f, contentSize.height / 2.0f);
}


@end

@interface MQBrowserPhoto ()
<UIScrollViewDelegate, UIGestureRecognizerDelegate>
{
    Photo * currentPhoto;
    
    UILabel * _locationLabel;
}
@property (nonatomic, strong) UIScrollView * scrollView;
@property (nonatomic, strong) NSArray * photos;
@property (nonatomic, assign) NSInteger currentIndex;
@property (nonatomic, weak) UIView * animation_superView;
@property (nonatomic, assign) CGRect animation_originFrame;
@end

@implementation MQBrowserPhoto


- (id)initWithPhotos:(NSArray *)photos Index:(NSInteger)index
{
    self = [super initWithFrame:[UIScreen mainScreen].bounds];
    if (self) {
        self.photos = photos;
        if (index > self.photos.count) {
            index = self.photos.count - 1;
        }
        self.currentIndex = index;
        [self initView];
    }
    return self;
}
- (id)initWithPhotos:(NSArray *)photos Index:(NSInteger)index SuperView:(UIView *)superView OriginFrame:(CGRect)originFrame
{
    self = [super initWithFrame:[UIScreen mainScreen].bounds];
    if (self) {
        self.photos = photos;
        if (index > self.photos.count) {
            index = self.photos.count - 1;
        }
        self.currentIndex = index;
        self.animation_superView = superView;
        self.animation_originFrame = originFrame;
        [self initView];
    }
    return self;
}

- (void)initView
{

    if (self.animation_superView) {
        self.backgroundColor = [UIColor clearColor];
        [UIView animateWithDuration:0.25 animations:^{
            self.backgroundColor = [UIColor blackColor];
        }];
    } else {
        self.backgroundColor = [UIColor blackColor];
    }
    
    [self addSubview:self.scrollView];
    self.scrollView.contentSize = CGSizeMake(self.photos.count * self.scrollView.frame.size.width, 0);
    [self layoutScrollView];
    
    UITapGestureRecognizer * tapScale = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapScale:)];
    tapScale.numberOfTapsRequired = 2;
    UITapGestureRecognizer * tapClose = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapClose:)];
    [tapClose requireGestureRecognizerToFail:tapScale];
 
    [self.scrollView addGestureRecognizer:tapScale];
    [self.scrollView addGestureRecognizer:tapClose];
    
    _locationLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.frame.size.height - 20, self.frame.size.width, 20)];
    _locationLabel.textColor = [UIColor whiteColor];
    _locationLabel.textAlignment = NSTextAlignmentCenter;
    _locationLabel.font = [UIFont systemFontOfSize:13];
    _locationLabel.text = [NSString stringWithFormat:@"%ld / %ld", self.currentIndex + 1,self.photos.count];
    [self addSubview:_locationLabel];
    
}

- (void)tapScale:(UITapGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateEnded) {
        [currentPhoto zoomToPoint:[sender locationInView:currentPhoto]];
    }
}

- (void)tapClose:(UITapGestureRecognizer *)sender
{
    if (sender.state != UIGestureRecognizerStateEnded) {
        return;
        
    }
    [UIView animateWithDuration:0.25 animations:^{
        self.transform = CGAffineTransformMakeScale(1.3, 1.3);
        self.alpha = 0.0f;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];

}

/**
 *  布局scrollView
 */
- (void)layoutScrollView
{
    for (Message * message in self.photos) {
        
        NSInteger index = [self.photos indexOfObject:message];
        
        CGRect frame = CGRectMake(index * self.scrollView.frame.size.width, 0, self.scrollView.frame.size.width, self.scrollView.frame.size.height);
        frame = CGRectInset(frame, 5, 5);
        
        Photo * photo = [[Photo alloc] initWithFrame:frame];
        photo.backgroundColor = [UIColor blackColor];
        photo.message = message;
        [self.scrollView addSubview:photo];
        
        if (index == self.currentIndex && self.animation_superView) {
            [photo downloadImage];
            [photo showAnimation:self.animation_superView OriginFrame:self.animation_originFrame];
            currentPhoto = photo;
            
        }
    }

    [self.scrollView setContentOffset:CGPointMake(self.currentIndex * self.scrollView.frame.size.width, 0) animated:YES];
    
}

- (UIScrollView *)scrollView
{
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        _scrollView.delegate = self;
        _scrollView.pagingEnabled = YES;
    }
    return _scrollView;
}


// MARK: - ScrollView Delegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [currentPhoto reductionZoom];
    CGFloat index =  scrollView.contentOffset.x / scrollView.frame.size.width;
    self.currentIndex = index;
    currentPhoto = scrollView.subviews[self.currentIndex];
    [currentPhoto downloadImage];
    _locationLabel.text = [NSString stringWithFormat:@"%ld / %ld", self.currentIndex + 1,self.photos.count];
}



@end
