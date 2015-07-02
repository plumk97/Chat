//
//  Chat_MoreOperationView.m
//  Chat
//
//  Created by 货道网 on 15/5/15.
//  Copyright (c) 2015年 李铁柱. All rights reserved.
//

#import "Chat_MoreOperationView.h"

@interface OperCollectionViewCell : UICollectionViewCell
{
    UIImageView * imageView;
    UILabel * titleLabel;
}

@property (nonatomic, weak) NSDictionary * dict;

@end
@implementation OperCollectionViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        imageView = [[UIImageView alloc] initWithFrame:CGRectMake((frame.size.width - 50) / 2, (frame.size.height - 50) / 2 - 10, 50, 50)];
        [self.contentView addSubview:imageView];
        
        titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, imageView.frame.origin.y + imageView.frame.size.height + 5, frame.size.width, 20)];
        titleLabel.font = [UIFont systemFontOfSize:12];
        titleLabel.textColor = [UIColor darkGrayColor  ];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:titleLabel];
        
    
    }
    return self;
}

- (void)setDict:(NSDictionary *)dict
{
    _dict = dict;
    
    imageView.image = [UIImage imageNamed:[dict objectForKey:@"image"]];
    titleLabel.text = [dict objectForKey:@"title"];
}


@end



@interface Chat_MoreOperationView ()
<UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UICollectionView * collectionView;
@property (nonatomic, strong) NSMutableArray * dataArr;
@property (nonatomic, copy) void (^selectBlock)(NSInteger);

@end

@implementation Chat_MoreOperationView


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor clearColor];
        
        [self addSubview:self.collectionView];
        [self.collectionView registerClass:[OperCollectionViewCell class] forCellWithReuseIdentifier:@"identifier"];
        
        
        
        self.dataArr = [[NSMutableArray alloc]initWithObjects:
  @{@"image" : @"aio_icons_pic@3x.png", @"title" : @"照片"},
  @{@"image" : @"aio_icons_camera@3x.png", @"title" : @"拍摄"},
  @{@"image" : @"aio_icons_freeaudio@3x.png", @"title" : @"电话"},
  @{@"image" : @"aio_icons_location@3x.png", @"title" : @"位置"}, nil];
        
    }
    
    return self;
}


- (UICollectionView *)collectionView
{
    if (!_collectionView) {
        
        UICollectionViewFlowLayout * layout = [[UICollectionViewFlowLayout alloc] init];
        layout.itemSize = CGSizeMake(self.frame.size.width / 3.0f, self.frame.size.height / 2.0f);
        layout.minimumInteritemSpacing = 0;
        layout.minimumLineSpacing = 0;
        _collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:layout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.backgroundColor = [UIColor clearColor];
    }
    return _collectionView;
}

- (void)setDidSelectItemIndex:(void (^)(NSInteger))block
{
    self.selectBlock = block;
}

// MARK: - CollectionView Delegate


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.dataArr.count;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    OperCollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"identifier" forIndexPath:indexPath];
    cell.dict = [self.dataArr objectAtIndex:indexPath.row];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.selectBlock) {
        self.selectBlock (indexPath.row);
    }
}


@end
