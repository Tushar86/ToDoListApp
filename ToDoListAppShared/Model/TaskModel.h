//
//  TaskModel.h
//  ToDoListAppShared
//
//  Created by Tushar  Verma on 11.03.24.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TaskModel : NSObject

@property (nonatomic, copy, readonly) NSString *name;
@property (nonatomic, assign, readonly) NSInteger level;
@property (nonatomic, copy, nullable) NSArray<TaskModel *> *subtasks;

- (instancetype)initWithName:(NSString *)name level:(NSInteger)level subtasks:(nullable NSArray<TaskModel *> *)subtasks;

@end

NS_ASSUME_NONNULL_END
