//
//  TaskOperations.h
//  ToDoListAppShared
//
//  Created by Tushar  Verma on 11.03.24.
//

#import <Foundation/Foundation.h>
#import <ToDoListAppShared/TaskList.h>
#import <ToDoListAppShared/CoreDataStack.h>

NS_ASSUME_NONNULL_BEGIN

@protocol TaskManagerDelegate <NSObject>

- (NSIndexPath *)indexPathForTask:(TaskList *)task;
- (void)subtasksMarkedAsCompleted:(NSArray<NSIndexPath *> *)indexPaths;

@end

@interface TaskOperations : NSObject

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, weak) id<TaskManagerDelegate> delegate;

+ (instancetype)sharedInstance;
- (void)addTask:(NSString *)name taskLevel:(NSInteger)level;
- (void)addSubtaskWithName:(NSString *)name subtaskLevel:(NSInteger)level atIndex:(NSInteger)indexValue parentTask:(TaskList *)parentTask;
- (NSArray<TaskList *> *)fetchTask;
- (void)updateTaskWithName:(NSString *)updatedName ofTask:(TaskList *)selectedTask;
- (void)deleteParentTaskAndSubtasks:(TaskList *)parentTask completion:(void (^)(NSArray<TaskList *> *))completion;
- (void)markSubtasksAsCompletedForTask:(TaskList *)task;

@end

NS_ASSUME_NONNULL_END
