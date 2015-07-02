//
//  Chat_MoreFaceView.m
//  Chat
//
//  Created by 货道网 on 15/6/12.
//  Copyright (c) 2015年 李铁柱. All rights reserved.
//

#import "Chat_MoreFaceView.h"
#import "EmojiEmoticons.h"
#import "EmojiTransport.h"
#import "EmojiMapSymbols.h"



@interface FaceCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) UILabel * titleLabel;
@property (nonatomic, strong) UIImageView * imageView;

@end

@implementation FaceCollectionViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _titleLabel = [[UILabel alloc] initWithFrame:self.bounds];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.font = [UIFont systemFontOfSize:25];
        [self.contentView addSubview:_titleLabel];
        
        _imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        _imageView.contentMode = UIViewContentModeCenter;
        [self addSubview:_imageView];
        
    }
    return self;
}


@end

@interface FaceCollectionViewLayout : UICollectionViewFlowLayout

@property (nonatomic, assign) NSInteger xNumber;
@property (nonatomic, assign) NSInteger yNumber;


@end
@implementation FaceCollectionViewLayout

- (CGSize)collectionViewContentSize
{
    CGFloat page = [self.collectionView numberOfItemsInSection:0] / 24.0f;
    if (page > (int)page) {
        page += 1;
    }
    return CGSizeMake((int)page * [UIScreen mainScreen].bounds.size.width, 0);
}
- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSMutableArray *layoutAttributes = [NSMutableArray array];
    // Cells
    // We call a custom helper method -indexPathsOfItemsInRect: here
    // which computes the index paths of the cells that should be included
    // in rect.
    
    NSInteger number = [self.collectionView numberOfItemsInSection:0];
    
    int x = 0, y = 0, page = 0;

    for (int i = 0; i < number; i++) {
        NSIndexPath * indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        UICollectionViewLayoutAttributes *attributes =
        [self layoutAttributesForItemAtIndexPath:indexPath];
        [layoutAttributes addObject:attributes];
        
        attributes.frame = CGRectMake(x * attributes.frame.size.width + page * self.collectionView.frame.size.width, y * attributes.frame.size.height, attributes.frame.size.width, attributes.frame.size.height);
        x ++;
        if (x >= _xNumber) {
            x = 0;
            y++;
            if (y >= _yNumber) {
                y = 0;
                page++;
            }
        }
    }

    return layoutAttributes;
}


@end

// MARK: 表情显示界面
@interface FaceCollectionView : UIView
<UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>
{
    UICollectionView * _collectionView;
    
    UIPageControl * _pageControl;
}

@property (nonatomic, assign) FaceType type;
@property (nonatomic, strong) NSArray * dataSoureArr;
@property (nonatomic, strong) FaceCollectionViewLayout * layout;;

@property (nonatomic, assign) Chat_MoreFaceView * faceView;
@end

@implementation FaceCollectionView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        

        
        _layout = [[FaceCollectionViewLayout alloc] init];
        _layout.xNumber = 6;
        _layout.yNumber = 4;
//        _layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _layout.itemSize = CGSizeMake(frame.size.width / _layout.xNumber, (frame.size.height - 20) / _layout.yNumber);
        _layout.minimumInteritemSpacing = 0;
        _layout.minimumLineSpacing = 0;
        
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height - 20) collectionViewLayout:_layout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.pagingEnabled = YES;
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.showsVerticalScrollIndicator = NO;
        [_collectionView registerClass:[FaceCollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
        [self addSubview:_collectionView];
        
        _pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, frame.size.height - 20, frame.size.width, 20)];
        _pageControl.pageIndicatorTintColor = [UIColor grayColor];
        _pageControl.currentPageIndicatorTintColor = [UIColor darkGrayColor];
        [self addSubview:_pageControl];

        [_collectionView addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:nil];
        
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    CGSize size;
    [[change objectForKey:@"new"] getValue:&size];
    _pageControl.numberOfPages = size.width / _collectionView.frame.size.width;

}


- (void)setDataSoureArr:(NSArray *)dataSoureArr
{
    NSMutableArray * mArr = [[NSMutableArray alloc] initWithArray:dataSoureArr];
    [mArr removeObjectsInRange:NSMakeRange(mArr.count - 8, 8)];

    UIImage * image = [UIImage imageNamed:@"aio_face_delete"];
    for (int i = 24; i < mArr.count; i+=24) {
        [mArr insertObject:image atIndex:i - 1];
    }
    [mArr addObject:image];
    
    _dataSoureArr = mArr;
    [_collectionView reloadData];
}


// MARK: - CollectionData Delgate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.dataSoureArr.count;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    FaceCollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    
    id object = [self.dataSoureArr objectAtIndex:indexPath.row];
    
    cell.titleLabel.text = @"";
    cell.imageView.image = nil;
    if ([object isKindOfClass:[NSString class]]) {
        cell.titleLabel.text = [self.dataSoureArr objectAtIndex:indexPath.row];
    } else {
        cell.imageView.image = [self.dataSoureArr objectAtIndex:indexPath.row];
    }
    
    
    
    return cell;
}

// MARK: - Collection Delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (_faceView.sendFace) {
        _faceView.sendFace ([self.dataSoureArr objectAtIndex:indexPath.row], self.type);
    }
}


- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    CGFloat page = scrollView.contentOffset.x / scrollView.frame.size.width;
    
    page = page > (int)page ? page + 1 : page;
    _pageControl.currentPage = page;
}

- (void)dealloc
{
    [_collectionView removeObserver:self forKeyPath:@"contentSize"];
}

@end

@interface FaceButton : UIButton

@end
@implementation FaceButton

- (void)drawRect:(CGRect)rect
{
    // 绘制左边的线条
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    CGContextSetLineWidth(ctx, 1 / [UIScreen mainScreen].scale / 2.0f);
    
    CGPoint points[2];
    points[0] = CGPointMake(rect.size.width, 0);
    points[1] = CGPointMake(rect.size.width, rect.size.height);
    
    CGContextAddLines(ctx, points, 2);
    CGContextDrawPath(ctx, kCGPathStroke);
}


@end

/**
 *  MARK: - 底部表情按钮
 */
@interface FaceBar : UIView
{
    UIScrollView * _scrollView;
    NSArray * _btns;
    FaceButton * _preButton;
}

@property (nonatomic, assign) Chat_MoreFaceView * faceView;

@end

@implementation FaceBar
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        _scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        _scrollView.alwaysBounceHorizontal = YES;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        [self addSubview:_scrollView];
    
        _btns = @[ [NSNumber numberWithInt:0x1F604] ];
        
        int index = 0;
        for (id value in _btns) {
            
            FaceButton * btn = nil;
            if ([value isKindOfClass:[NSNumber class]]) {
                btn = [self defulatButtonTitle:[Emoji emojiWithCode:[value intValue]] Image:nil];
            }
            if (index == 0) {
                [self faceBtnClick:btn];
            }
            [btn addTarget:self action:@selector(faceBtnClick:) forControlEvents:UIControlEventTouchUpInside];
            btn.frame = CGRectMake(0 + index * (frame.size.height + 10), 0, frame.size.height + 10, frame.size.height);
            [_scrollView addSubview:btn];
            index++;
        }
        
        FaceButton * btn = [self defulatButtonTitle:@"发送" Image:nil];
        btn.frame = CGRectMake(frame.size.width - (frame.size.height + 10), 0, frame.size.height + 10, frame.size.height);
        [btn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont systemFontOfSize:15];
        [btn addTarget:self action:@selector(sendClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btn];
    }
    return self;
}

- (FaceButton *)defulatButtonTitle:(NSString *)title Image:(UIImage *)image
{
    FaceButton * btn = [FaceButton buttonWithType:UIButtonTypeCustom];
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setImage:image forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:20];
    
    
    return btn;
}

- (void)sendClick:(UIButton *)sender
{
    if (_faceView.sendClick) {
        _faceView.sendClick();
    }
}

- (void)faceBtnClick:(FaceButton *)sender
{
    _preButton.backgroundColor = [UIColor clearColor];
    sender.backgroundColor = [UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:1];
    
    
    _preButton = sender;
}



- (void)drawRect:(CGRect)rect
{
    // 绘制顶部的线条
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    CGContextSetLineWidth(ctx, 1 / [UIScreen mainScreen].scale / 2.0f);
    
    CGPoint points[2];
    points[0] = CGPointMake(0, 0);
    points[1] = CGPointMake(rect.size.width, 0);
    
    CGContextAddLines(ctx, points, 2);
    CGContextDrawPath(ctx, kCGPathStroke);
    
}

@end

// MARK: - 聊天表情界面
@interface Chat_MoreFaceView ()

@property (nonatomic, strong) FaceBar * faceBar;
@property (nonatomic, strong) FaceCollectionView * collectionView;

@end

@implementation Chat_MoreFaceView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        _faceBar = [[FaceBar alloc] initWithFrame:CGRectMake(0, frame.size.height - 40, frame.size.width, 40)];
        _faceBar.faceView = self;
        [self addSubview:_faceBar];
        
        
        _collectionView = [[FaceCollectionView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height - 40)];
        _collectionView.faceView = self;
        [self addSubview:_collectionView];
        
        NSMutableArray * emojiArr = [NSMutableArray new];
        [emojiArr addObjectsFromArray:[EmojiEmoticons allEmoticons]];
        [emojiArr addObjectsFromArray:[EmojiTransport allTransport]];
        [emojiArr addObjectsFromArray:[EmojiMapSymbols allMapSymbols]];
        _collectionView.dataSoureArr = emojiArr;
        
        
    }
    return self;
}





@end
