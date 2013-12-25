//
//  RKRoute.m
//  RestKit
//
//  Created by Blake Watters on 5/31/12.
//  Copyright (c) 2012 RestKit. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import "RKRoute.h"

@interface RKRoute ()
@property (nonatomic, strong, readwrite) NSString *name;
@property (nonatomic, strong, readwrite) Class objectClass;
@property (nonatomic, assign, readwrite) RKHTTPMethodOptions method;
@property (nonatomic, strong, readwrite) CSURITemplate *URITemplate;
@end

@interface RKNamedRoute : RKRoute
@end

@interface RKClassRoute : RKRoute
@end

@interface RKRelationshipRoute : RKRoute
@end

@implementation RKRoute

+ (instancetype)routeWithName:(NSString *)name URITemplateString:(NSString *)URITemplateString method:(RKHTTPMethodOptions)method
{
    NSParameterAssert(name);
    NSParameterAssert(URITemplateString);
    if (!RKIsSpecificHTTPMethod(method)) [NSException raise:NSInvalidArgumentException format:@"The `method` parameter must specify a single, non-ambiguous HTTP method. Bitmask values and `RKHTTPMethodAny` are invalid arguments."];
    NSError *error = nil;
    CSURITemplate *URITemplate = [CSURITemplate URITemplateWithString:URITemplateString error:&error];
    if (!URITemplate && error) [NSException raise:NSInvalidArgumentException format:@"Invalid URI Template: %@", [error localizedDescription]];
    RKNamedRoute *route = [RKNamedRoute new];
    route.name = name;
    route.URITemplate = URITemplate;
    route.method = method;
    return route;
}

+ (instancetype)routeWithClass:(Class)objectClass URITemplateString:(NSString *)URITemplateString method:(RKHTTPMethodOptions)method
{
    NSParameterAssert(objectClass);
    NSParameterAssert(URITemplateString);
    NSError *error = nil;
    CSURITemplate *URITemplate = [CSURITemplate URITemplateWithString:URITemplateString error:&error];
    if (!URITemplate && error) [NSException raise:NSInvalidArgumentException format:@"Invalid URI Template: %@", [error localizedDescription]];
    RKClassRoute *route = [RKClassRoute new];
    route.objectClass = objectClass;
    route.URITemplate = URITemplate;
    route.method = method;
    return route;
}

+ (instancetype)routeWithRelationshipName:(NSString *)relationshipName objectClass:(Class)objectClass URITemplateString:(NSString *)URITemplateString method:(RKHTTPMethodOptions)method
{
    NSParameterAssert(relationshipName);
    NSParameterAssert(objectClass);
    NSParameterAssert(URITemplateString);
    NSError *error = nil;
    CSURITemplate *URITemplate = [CSURITemplate URITemplateWithString:URITemplateString error:&error];
    if (!URITemplate && error) [NSException raise:NSInvalidArgumentException format:@"Invalid URI Template: %@", [error localizedDescription]];
    RKRelationshipRoute *route = [RKRelationshipRoute new];
    route.name = relationshipName;
    route.objectClass = objectClass;
    route.URITemplate = URITemplate;
    route.method = method;
    return route;
}

- (id)init
{
    self = [super init];
    if (self) {
        if ([self isMemberOfClass:[RKRoute class]]) {
            @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                           reason:[NSString stringWithFormat:@"%@ is not meant to be directly instantiated. Use one of the initializer methods instead.",
                                                   NSStringFromClass([self class])]
                                         userInfo:nil];
        }
    }

    return self;
}

- (BOOL)isNamedRoute
{
    return NO;
}

- (BOOL)isClassRoute
{
    return NO;
}

- (BOOL)isRelationshipRoute
{
    return NO;
}

@end

@implementation RKNamedRoute

- (BOOL)isNamedRoute
{
    return YES;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %p name=%@ method=%@ pathPattern=%@>",
            NSStringFromClass([self class]), self, self.name, RKStringDescribingHTTPMethods(self.method), self.URITemplate];
}

@end

@implementation RKClassRoute

- (BOOL)isClassRoute
{
    return YES;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %p objectClass=%@ method=%@ pathPattern=%@>",
            NSStringFromClass([self class]), self, NSStringFromClass(self.objectClass),
            RKStringDescribingHTTPMethods(self.method), self.URITemplate];
}

@end

@implementation RKRelationshipRoute

- (BOOL)isRelationshipRoute
{
    return YES;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %p relationshipName=%@ objectClass=%@ method=%@ pathPattern=%@>",
            NSStringFromClass([self class]), self, self.name, NSStringFromClass(self.objectClass),
            RKStringDescribingHTTPMethods(self.method), self.URITemplate];
}

@end
