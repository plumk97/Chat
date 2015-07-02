//
//  Message.m
//  Chat
//
//  Created by 货道网 on 15/5/9.
//  Copyright (c) 2015年 李铁柱. All rights reserved.
//

#import "Message.h"
#import "Session.h"

#import "MQEncodeAudio.h"

@implementation Message

@dynamic messageId;
@dynamic state;
@dynamic content;
@dynamic isSender;
@dynamic time;
@dynamic type;
@dynamic session;


@dynamic localPath;
@dynamic locationThumbanilImagePath;
@dynamic remotePath;
@dynamic thumbnailPath;
@dynamic imageHeight;
@dynamic imageWidth;


@dynamic locationName;
@dynamic longitude;
@dynamic latitude;

@dynamic audioLocationPath;
@dynamic audioRemotePath;
@dynamic audioPlayTime;

@synthesize image;
@synthesize isPlaying;

/**
 *  获取默认message
 *
 *  @return message 对象
 */
+ (Message *)defaultMessage
{
    Message * message = [NSEntityDescription insertNewObjectForEntityForName:@"Message" inManagedObjectContext:[MQChatManager sharedInstance].managedObjectContext];
    
    return message;
}

/**
 *  根据字典生成message对象
 *
 *  @param dict 字典
 *
 *  @return message
 */
+ (Message *)messageWithDict:(NSDictionary *)dict
{
    Session * session = [MQChatManager sessionForUserName:[dict objectForKey:@"from"] Default:NO];
    
    Message * message = [Message defaultMessage];
    message.session = session;
    message.messageId = [dict objectForKey:@"messageId"];
    message.time = message.messageId;
    message.type = [NSNumber numberWithInteger:[[dict objectForKey:@"type"] integerValue]];
    message.isSender = [NSNumber numberWithBool:[session.to isEqualToString:[MQChatManager sharedInstance].username]];
    message.state = [NSNumber numberWithInt:MessageSendState_Succeed];
    
    message.content = [dict objectForKey:@"content"];
    
    message.remotePath = [dict objectForKey:@"remotePath"];
    message.thumbnailPath = [dict objectForKey:@"thumbnailPath"];
    message.imageWidth = [dict objectForKey:@"imageWidth"];
    message.imageHeight = [dict objectForKey:@"imageHeight"];

    message.locationName = [dict objectForKey:@"locationName"];
    message.latitude = [dict objectForKey:@"latitude"];
    message.longitude = [dict objectForKey:@"longitude"];
    
    message.audioRemotePath = [dict objectForKey:@"audioRemote"];
    message.audioPlayTime = [dict objectForKey:@"audipPlayTime"];

    return message;
}

/**
 *  根据字典生成message对象
 *
 *  @param dict 字典
 *  @param session 指定那个会话
 *  @return message
 */
+ (Message *)messageWithDict:(NSDictionary *)dict Session:(Session *)session
{
    Message * message = [Message messageWithDict:dict];
    message.session = session;
    return message;
}

/**
 *  转换为字典形式 用于发送数据
 *
 *  @return 字典
 */
- (NSDictionary *)conversionToDictionary
{
    NSString * dataStr = nil;
    if (image) {
        NSData * data = UIImageJPEGRepresentation(image, 0.6);
        

        dataStr = [data base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];

    }
    
    NSMutableDictionary * mDict = [[NSMutableDictionary alloc] initWithDictionary:@{@"messageId" : self.messageId,
                                                                                    @"from" : self.session.from,
                                                                                    @"to" : self.session.to,
                                                                                    @"type" : self.type,
                                                                                    @"time" : self.time}];

    switch ([self.type integerValue]) {
        case MessageType_Text:
            [mDict setObject:self.content forKey:@"content"];
            break;
        case MessageType_Image:
            [mDict setObject:dataStr forKey:@"image"];
            break;
        case MessageType_Location:
            [mDict setObject:self.locationName forKey:@"locationName"];
            [mDict setObject:self.latitude forKey:@"latitude"];
            [mDict setObject:self.longitude forKey:@"longitude"];
            break;
        case MessageType_Audio:
        {
            NSData * data = [MQEncodeAudio convertWavToAmrFile:[NSData dataWithContentsOfFile:self.audioLocationPath]];
            
            [mDict setObject:[data base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength] forKey:@"audioData"];
            [mDict setObject:self.audioPlayTime forKey:@"audioPlayTime"];
        }
            break;
        default:
            break;
    }

    
    return mDict;
}

/**
 *  克隆message
 *
 *  @return message
 */
- (Message *)clone
{
    Message * message = [Message defaultMessage];
    message.type = self.type;
    message.session = self.session;
    message.messageId = [[NSString alloc] initWithFormat:@"%f",[[NSDate date] timeIntervalSince1970]];;
    message.time = message.messageId;
    message.state = self.state;
    message.isSender = self.isSender;
    
    message.content = self.content;
    
    message.localPath = self.localPath;
    message.locationThumbanilImagePath = self.locationThumbanilImagePath;
    message.remotePath = self.remotePath;
    message.thumbnailPath = self.thumbnailPath;
    message.imageWidth = self.imageWidth;
    message.imageHeight = self.imageHeight;
    message.image = self.image;
    
    message.locationName = self.locationName;
    message.latitude = self.latitude;
    message.longitude = self.longitude;
    
    message.audioLocationPath = self.audioLocationPath;
    message.audioRemotePath = self.audioRemotePath;
    message.audioPlayTime = self.audioPlayTime;
    message.isPlaying = self.isPlaying;
    
    NSError * error;
    [[MQChatManager sharedInstance].managedObjectContext save:&error];
    if (error) {
        NSLog(@"%@",[error localizedDescription]);
    }
    
    return message;
}

@end
