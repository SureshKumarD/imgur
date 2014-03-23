//
//  ImgurSession_Tests.m
//  ImgurSession Tests
//
//  Created by Geoff MacDonald on 2014-03-07.
//  Copyright (c) 2014 GeoffMacDonald. All rights reserved.
//

#import "IMGTestCase.h"

#warning: Tests requires client id, client secret filled out in tests plist
#warning: Tests must have refresh token filled out in tests plist in order to work on iPhone
#warning: Test user must have at least: one notification, one comment, one image post, one favourtie


@interface IMGAccountTests : IMGTestCase

@end

@implementation IMGAccountTests

#pragma mark - Test Account endpoints


- (void)testAccountLoadMe{

    __block BOOL success;
    
    [self getTest: @{
                @"id": @10660555,
                @"url": @"geoffmacd",
                @"bio": [NSNull null],
                @"reputation": @0,
                @"created": @1395605015,
                @"pro_expiration": @NO
                }];
    
    [IMGAccountRequest accountWithUser:@"me" success:^(IMGAccount *account) {
        
        success = YES;
        
    } failure:failBlock];
    
    
    expect(success).will.beTruthy();
}

- (void)testAccountLoadMyFavs{
    
    __block BOOL isSuccess;
    
    [IMGAccountRequest accountFavouritesWithSuccess:^(NSArray * favorites) {
        
        isSuccess = YES;
        
    } failure:failBlock];
    
    expect(isSuccess).will.beTruthy();
}

- (void)testAccountLoadMySubmissions{
    
    __block BOOL isSuccess;
    
    [IMGAccountRequest accountSubmissionsWithUser:@"me" withPage:0 success:^(NSArray * submissions) {
        
        isSuccess = YES;
        
    } failure:failBlock];
    
    expect(isSuccess).will.beTruthy();
}

- (void)testAccountSettingsLoad{
    
    __block IMGAccountSettings *set;
    
    [IMGAccountRequest accountSettings:^(IMGAccountSettings *settings) {
        
        set = settings;

    } failure: failBlock];
    
    expect(set).willNot.beNil();
}

- (void)testAccountSettingsChange{
    
    __block IMGAccountSettings *set;
    
    [IMGAccountRequest changeAccountWithBio:@"test bio" messagingEnabled:YES publicImages:YES albumPrivacy:IMGAlbumPublic acceptedGalleryTerms:YES success:^{
        
        [IMGAccountRequest accountSettings:^(IMGAccountSettings *settings) {
            
            
            [IMGAccountRequest changeAccountWithBio:@"test bio 2" success:^{
                
                [IMGAccountRequest accountSettings:^(IMGAccountSettings *settings) {
                    
                    set = settings;
                    
                } failure:failBlock];
                
            } failure:failBlock];
            
        } failure:failBlock];
        
    } failure:failBlock];
    
    expect(set).willNot.beNil();
}

- (void)testAccountReplies{
    
    __block BOOL isSuccess;
    
    [IMGAccountRequest accountReplies:^(NSArray * replies) {

        [IMGAccountRequest accountRepliesWithFresh:NO success:^(NSArray * oldReplies) {
        
            isSuccess = YES;

        } failure:failBlock];
        
    } failure:failBlock];
    
    expect(isSuccess).will.beTruthy();
}

- (void)testAccountComments{
    
    __block BOOL isSuccess;
    
    [IMGAccountRequest accountCommentIDsWithUser:@"me" success:^(NSArray * commentIds) {

        if([commentIds firstObject]){
            [IMGAccountRequest accountCommentWithID:[[commentIds firstObject] integerValue] success:^(IMGComment * firstComment) {

                [IMGAccountRequest accountCommentsWithUser:@"me" success:^(NSArray * comments) {
                    
                    [IMGAccountRequest accountCommentCount:@"me" success:^(NSUInteger numcomments) {

                        expect([comments count] == numcomments ).to.beTruthy();
                        isSuccess = YES;

                    } failure:failBlock];
                } failure:failBlock];
            } failure:failBlock];
        } else {
            isSuccess = YES;
        }
    } failure:failBlock];
    
    expect(isSuccess).will.beTruthy();
}

- (void)testAccountImages{
    
    __block BOOL isSuccess;
    
    [IMGAccountRequest accountImageIDsWithUser:@"me" success:^(NSArray * images) {
        
        if([images firstObject]){
            [IMGAccountRequest accountImageWithID:[images firstObject] success:^(IMGImage * image) {
                
                [IMGAccountRequest accountImagesWithUser:@"me" withPage:0 success:^(NSArray * images) {
                        
                    [IMGAccountRequest accountImageCount:@"me" success:^(NSUInteger num) {
                        
                        expect(num).beGreaterThan(0);
                        isSuccess = YES;
                        
                    } failure:failBlock];
                } failure:failBlock];
            } failure:failBlock];
        } else {
            isSuccess = YES;
        }
    } failure:failBlock];
    
    expect(isSuccess).will.beTruthy();
}

- (void)testAccountAlbums{
    
    __block BOOL isSuccess;
    
    [IMGAccountRequest accountAlbumIDsWithUser:@"me" success:^(NSArray * albums) {
        
        if([albums firstObject]){
            [IMGAccountRequest accountAlbumWithID:[albums firstObject] success:^(IMGAlbum * album) {
                
                [IMGAccountRequest accountAlbumsWithUser:@"me" withPage:0 success:^(NSArray * albums) {
                    
                    [IMGAccountRequest accountAlbumCountWithUser:@"me" success:^(NSUInteger num) {
                        
                        expect(num).beGreaterThan(0);
                        isSuccess = YES;
                        
                    } failure:failBlock];
                } failure:failBlock];
            } failure:failBlock];
        } else {
            isSuccess = YES;
        }
    } failure:failBlock];
    
    expect(isSuccess).will.beTruthy();
}

-(void)testAccountCommentDelete{
    
    __block BOOL isDeleted;
    
    [self postTestImage:^(IMGImage * image, void(^success)()) {
        
        
        [IMGCommentRequest submitComment:@"test comment" withImageID:image.imageID withParentID:0 success:^(NSUInteger commentId) {
                
            [IMGAccountRequest accountDeleteCommentWithID:commentId success:^{
                
                success();
                isDeleted = YES;
                
            } failure:failBlock];
            
        } failure:failBlock];
    }];
    
    expect(isDeleted).will.beTruthy();
}

-(void)testAccountImageDelete{
    
    __block BOOL isDeleted;
    
    [self postTestImage:^(IMGImage * image, void(^success)()) {

        [IMGAccountRequest accountDeleteImageWithHash:image.deletehash success:^() {
            
            success();
            isDeleted = YES;
    
        } failure:failBlock];
    }];
    
    expect(isDeleted).will.beTruthy();
}

-(void)testAccountAlbumDelete{
    
    __block BOOL isDeleted;
    
    [self postTestAlbumWithOneImage:^(IMGAlbum * album, void(^success)()) {
        
        [IMGAccountRequest accountDeleteAlbumWithID:album.albumID success:^{
            
            success();
            isDeleted = YES;
            
        } failure:failBlock];
    }];
    
    expect(isDeleted).will.beTruthy();
}

@end
