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

@property (strong, nonatomic) NSMutableArray<TaskModel *> *tasks;
@property (strong, nonatomic) NSMutableArray<TaskModel *> *allTasks; // Flat list for table view

@property (strong, nonatomic) NSMutableArray *dataArray;
@property (strong, nonatomic) NSUserDefaults *defaults;



-(instancetype)init;
-(NSMutableArray*)loadData;
-(void)flattenTasks:(NSArray<TaskModel *> *)tasks withSelectedParent:(nullable TaskModel *)isParentSelected;
-(NSArray<TaskModel *> *)loadDataFromPlist;
-(void)updateValueInPlist:(NSString *)key newValue:(NSString *)newValue atIndex:(NSInteger)index;
- (void)deleteTask:(NSInteger)index;

@end

NS_ASSUME_NONNULL_END
