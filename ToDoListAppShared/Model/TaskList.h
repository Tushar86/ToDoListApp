//
//  TaskList.h
//  ToDoListAppShared
//
//  Created by Tushar  Verma on 27.03.24.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN

@interface TaskList : NSManagedObject

@property (nonatomic, strong) NSString *hierarchicalNumber;
@property (nonatomic, strong) NSString *taskName;
@property (nonatomic) BOOL isCompleted;
@property (nonatomic, readwrite) NSInteger level;
@property (nonatomic, strong) TaskList *parentTask;
@property (nonatomic, strong) NSMutableSet<TaskList *> *subtask;


@end

NS_ASSUME_NONNULL_END
