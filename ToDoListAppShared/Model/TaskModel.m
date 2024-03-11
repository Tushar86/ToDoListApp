//
//  TaskModel.m
//  ToDoListAppShared
//
//  Created by Tushar  Verma on 11.03.24.
//

#import "TaskModel.h"

@implementation TaskModel

- (instancetype)initWithName:(NSString *)name level:(NSInteger)level subtasks:(nullable NSArray<TaskModel *> *)subtasks {
    self = [super init];
    if (self) {
        _name = [name copy];
        _level = level;
        _subtasks = [subtasks copy];
    }
    return self;
}

@end
