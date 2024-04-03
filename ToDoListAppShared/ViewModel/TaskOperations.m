//
//  TaskOperations.m
//  ToDoListAppShared
//
//  Created by Tushar  Verma on 11.03.24.
//

#import "TaskOperations.h"

@implementation TaskOperations

+ (instancetype)sharedInstance {
    static TaskOperations *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[TaskOperations alloc] init];
    });
    return sharedInstance;
}

- (void)addTask:(NSString *)name taskLevel:(NSInteger)level{
    NSManagedObjectContext *context = [[[CoreDataStack sharedInstance] managedObjectContext]retain];
    TaskList *newTask = [[NSEntityDescription insertNewObjectForEntityForName:@"TaskList" inManagedObjectContext:context]retain];
    newTask.taskName = name;
    newTask.level = level;
    newTask.isCompleted = NO;
    newTask.hierarchicalNumber = [[self generateHierarchicalNumberForParent:nil inContext:context]retain];
    
    [[CoreDataStack sharedInstance] saveContext];
    [context release];
    [newTask release];
}

- (void)addSubtaskWithName:(NSString *)name subtaskLevel:(NSInteger)level parentTask:(TaskList *)parentTask {
    NSManagedObjectContext *context = [[[CoreDataStack sharedInstance] managedObjectContext]retain];
    TaskList *newTask = [[NSEntityDescription insertNewObjectForEntityForName:@"TaskList" inManagedObjectContext:context]retain];
    newTask.taskName = name;
    newTask.level = level;
    newTask.isCompleted = NO;
    newTask.parentTask = parentTask;
    newTask.hierarchicalNumber = [[self generateHierarchicalNumberForParent:parentTask inContext:context]retain];
    
    NSMutableSet *mutableSubtasks = [[parentTask.subtask mutableCopy]autorelease];
    [mutableSubtasks addObject:newTask];
    parentTask.subtask = [mutableSubtasks copy];
    
    [[CoreDataStack sharedInstance]saveContext];
    
    [context release];
    [newTask release];
}

- (NSString *)generateHierarchicalNumberForParent:(TaskList *)parent inContext:(NSManagedObjectContext *)context {
    if (!parent) {
        // If the task has no parent, assign a simple number
        NSFetchRequest<TaskList *> *fetchRequest = [TaskList fetchRequest];
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"parentTask == nil"];
        NSInteger count = [context countForFetchRequest:fetchRequest error:nil];
        return [NSString stringWithFormat:@"%ld", (long)(count)];
    } else {
        // If the task has a parent, generate a hierarchical number based on its parent
        NSFetchRequest<TaskList *> *fetchRequest = [TaskList fetchRequest];
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"parentTask == %@", parent];
        NSInteger count = [context countForFetchRequest:fetchRequest error:nil];
        NSString *parentNumber = parent.hierarchicalNumber ?: @"0";
        return [NSString stringWithFormat:@"%@.%ld", parentNumber, (long)(count)];
    }
}

- (NSArray<TaskList *> *)fetchTask{
    NSManagedObjectContext *context = [[CoreDataStack sharedInstance] managedObjectContext];
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"TaskList"];
    
    // Create a sort descriptor to sort tasks by the 'level' attribute
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"hierarchicalNumber" ascending:YES selector:@selector(localizedStandardCompare:)];
    fetchRequest.sortDescriptors = @[sortDescriptor];
    
    // Perform the fetch request
    NSError *error = nil;
    NSArray<TaskList *> *fetchedTasks = [context executeFetchRequest:fetchRequest error:&error];
    if (error) {
        NSLog(@"Failed to fetch tasks: %@", error);
        return @[];
    }
    return fetchedTasks;
}

- (void)updateTaskWithName:(NSString *)updatedName ofTask:(TaskList *)selectedTask{
    selectedTask.taskName = updatedName;
    [[CoreDataStack sharedInstance] saveContext];
}

- (void)deleteParentTaskAndSubtasks:(TaskList *)parentTask completion:(void (^)(NSArray<TaskList *> *))completion {
    NSManagedObjectContext *backgroundContext = [[CoreDataStack sharedInstance] managedObjectContext];
    [backgroundContext performBlock:^{
        NSMutableArray<TaskList *> *deletedTasks = [NSMutableArray arrayWithObject:parentTask];
        [deletedTasks addObjectsFromArray:[self collectSubtasksToDeleteForParentTask:parentTask]];
        
        for (TaskList *task in deletedTasks) {
            [backgroundContext deleteObject:task];
        }
        
        NSError *error = nil;
        if (![backgroundContext save:&error]) {
            NSLog(@"Error saving context: %@", error);
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(@[]);
            });
            return;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(deletedTasks);
        });
    }];
}

- (NSArray<TaskList *> *)collectSubtasksToDeleteForParentTask:(TaskList *)parentTask {
    NSMutableArray<TaskList *> *subtasks = [NSMutableArray array];
    for (TaskList *subtask in [parentTask.subtask allObjects]) {
        [subtasks addObject:subtask];
        [subtasks addObjectsFromArray:[self collectSubtasksToDeleteForParentTask:subtask]];
    }
    return subtasks;
}

- (void)markSubtasksAsCompletedForTask:(TaskList *)task {
    NSMutableSet<NSIndexPath *> *updatedIndexPaths = [NSMutableSet set];
    BOOL isCompleted = !task.isCompleted;
    [self markSubtasksAsCompletedForSubtask:task parentCurrentState:isCompleted updatedIndexPaths:updatedIndexPaths];
    
    if (!isCompleted) {
        [self uncheckRelatedParentTasksForTask:task updatedIndexPaths:updatedIndexPaths];
    }
    else {
        // Check if all parent tasks are completed
        [self checkRelatedParentTasksForTask:task updatedIndexPaths:updatedIndexPaths];
    }
    
    // Send back the updated index paths to reload the rows
    if ([self.delegate respondsToSelector:@selector(subtasksMarkedAsCompleted:)]) {
        [self.delegate subtasksMarkedAsCompleted:updatedIndexPaths.allObjects];
    }
    [[CoreDataStack sharedInstance] saveContext];
}

- (void)markSubtasksAsCompletedForSubtask:(TaskList *)subtask parentCurrentState:(BOOL)isCompleted updatedIndexPaths:(NSMutableSet<NSIndexPath *> *)updatedIndexPaths {
    subtask.isCompleted = isCompleted;
    
    NSIndexPath *indexPath = [self.delegate indexPathForTask:subtask];
    if (indexPath) {
        [updatedIndexPaths addObject:indexPath];
    }
    
    for (TaskList *nestedSubtask in subtask.subtask) {
        [self markSubtasksAsCompletedForSubtask:nestedSubtask parentCurrentState:isCompleted updatedIndexPaths:updatedIndexPaths];
    }
}

- (void)uncheckRelatedParentTasksForTask:(TaskList *)task updatedIndexPaths:(NSMutableSet<NSIndexPath *> *)updatedIndexPaths {
    TaskList *parentTask = task.parentTask;
    while (parentTask) {
        parentTask.isCompleted = NO;
        NSIndexPath *indexPath = [self.delegate indexPathForTask:parentTask];
        if (indexPath) {
            [updatedIndexPaths addObject:indexPath];
        }
        parentTask = parentTask.parentTask;
    }
}

- (void)checkRelatedParentTasksForTask:(TaskList *)task updatedIndexPaths:(NSMutableSet<NSIndexPath *> *)updatedIndexPaths {
    TaskList *parentTask = task.parentTask;
    while (parentTask) {
        BOOL allChildrenCompleted = YES;
        for (TaskList *subtask in parentTask.subtask) {
            if (!subtask.isCompleted) {
                allChildrenCompleted = NO;
                break;
            }
        }
        if (allChildrenCompleted) {
            parentTask.isCompleted = YES;
            NSIndexPath *indexPath = [self.delegate indexPathForTask:parentTask];
            if (indexPath) {
                [updatedIndexPaths addObject:indexPath];
            }
        } else {
            // If any child task is incomplete, stop checking parents
            break;
        }
        parentTask = parentTask.parentTask;
    }
}

@end
