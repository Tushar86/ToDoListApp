//
//  TaskOperations.h
//  ToDoListAppShared
//
//  Created by Tushar  Verma on 11.03.24.
//

#import <Foundation/Foundation.h>
#import <ToDoListAppShared/TaskModel.h>

NS_ASSUME_NONNULL_BEGIN

@interface TaskOperations : NSObject

@property (copy, nonatomic) NSMutableArray<TaskModel *> *tasks;

-(instancetype)init;
-(NSMutableArray*)loadData;
-(void)flattenTasks:(NSArray<TaskModel *> *)tasks withSelectedParent:(nullable TaskModel *)isParentSelected;
-(NSArray<TaskModel *> *)loadDataFromPlist;
-(void)updateValueInPlist:(NSString *)key newValue:(NSString *)newValue atIndex:(NSInteger)index;
- (void)deleteTask:(NSInteger)index;

@end

NS_ASSUME_NONNULL_END
