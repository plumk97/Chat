//
//  AudioSocket.m
//  AudioSocket
//
//  Created by li on 15/7/1.
//  Copyright (c) 2015年 li. All rights reserved.
//

#import "AudioSocket.h"
#import "AsyncSocket.h"

@interface AudioSocket ()
<AsyncSocketDelegate>
{
    AsyncSocket * _socket;
    AsyncSocket * _clientSocket;
    
    void (^block_status) (AudioSocketConnectStatus status);
    void (^block_receive) (NSData * data);
}

@end

@implementation AudioSocket

- (id)init {
    self = [super init];
    if (self) {
        _socket = [[AsyncSocket alloc] initWithDelegate:self];
        
        self.status = AudioSocketConnectStatus_Disconnect;
        
        [self addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    }
    return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    if (block_status) {
        block_status (self.status);
    }
    
}

- (NSInteger)bindServerPort {
    
    NSInteger port = arc4random() % 50000 + 10000;
    NSError * error = nil;
    [_socket acceptOnPort:port error:&error];
    while (error) {
        port = arc4random() % 50000 + 10000;
        [_socket acceptOnPort:port error:&error];
    }
    return port;
}

- (void)connectionIpaddress:(NSString *)ipAddress Port:(NSInteger)port {
    
    NSError * error = nil;
    [_socket connectToHost:ipAddress onPort:port error:&error];
}

- (void)writeData:(NSData *)data {
    
    if (self.status == AudioSocketConnectStatus_Disconnect) {
        return;
    }
    if (_clientSocket) {
        [_clientSocket writeData:data withTimeout:10 tag:0];
    } else {
        [_socket writeData:data withTimeout:10 tag:0];
    }
}

- (void)disconnection {
    [_socket disconnectAfterReadingAndWriting];
    [_clientSocket disconnectAfterReadingAndWriting];
}

- (void)setConnectStatusChange:(void (^)(AudioSocketConnectStatus status))block {
    block_status = block;
}

- (void)setReceiveData:(void (^)(NSData *))block {
    block_receive = block;
}

// MARK: - AsyncSocket Delegate


/**
 * Called when a socket disconnects with or without error.  If you want to release a socket after it disconnects,
 * do so here. It is not safe to do that during "onSocket:willDisconnectWithError:".
 *
 * If you call the disconnect method, and the socket wasn't already disconnected,
 * this delegate method will be called before the disconnect method returns.
 **/
- (void)onSocketDidDisconnect:(AsyncSocket *)sock {
    NSLog(@"连接断开");
    self.status = AudioSocketConnectStatus_Disconnect;
}

/**
 * Called when a socket accepts a connection.  Another socket is spawned to handle it. The new socket will have
 * the same delegate and will call "onSocket:didConnectToHost:port:".
 **/
- (void)onSocket:(AsyncSocket *)sock didAcceptNewSocket:(AsyncSocket *)newSocket {
    
    _clientSocket = newSocket;
    [_clientSocket readDataWithTimeout:-1 tag:0];
    self.status = AudioSocketConnectStatus_Connect;
    NSLog(@"新客户连接");
}


/**
 * Called when a socket connects and is ready for reading and writing.
 * The host parameter will be an IP address, not a DNS name.
 **/
- (void)onSocket:(AsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port {
    
    [sock readDataWithTimeout:-1 tag:0];
    self.status = AudioSocketConnectStatus_Connect;
    NSLog(@"连接服务器");
}

/**
 * Called when a socket has completed reading the requested data into memory.
 * Not called if there is an error.
 **/
- (void)onSocket:(AsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
 
    if (block_receive) {
        block_receive(data);
    }
    [sock readDataWithTimeout:-1 tag:0];
}

/**
 * Called when a socket has completed writing the requested data. Not called if there is an error.
 **/
- (void)onSocket:(AsyncSocket *)sock didWriteDataWithTag:(long)tag {
    
}


@end
