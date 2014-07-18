//
//  ModelConstants.h
//  iMods
//
//  Created by Ryan Feng on 7/17/14.
//  Copyright (c) 2014 Ryan Feng. All rights reserved.
//

typedef enum {
    SiteAdmin = 0,
    Admin = 1,
    NormalUser = 100
} UserRole;

typedef enum {
    CreditCard = 0,
    Paypal = 1,
} PaymentType;

typedef enum {
    OrderPlaced = 0,
    OrderCompleted = 1,
    OrderCancelled = 2
} OrderStatus;