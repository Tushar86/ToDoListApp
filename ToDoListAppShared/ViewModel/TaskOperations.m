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
    NSManagedObjectContext *context = [[CoreDataStack sharedInstance] managedObjectContext];
    TaskList *newTask = [NSEntityDescription insertNewObjectForEntityForName:@"TaskList" inManagedObjectContext:context];
    newTask.taskName = name;
    newTask.level = level;
    newTask.isCompleted = NO;
    newTask.hierarchicalNumber = [self generateHierarchicalNumberForParent:nil inContext:context];
    
    [[CoreDataStack sharedInstance] saveContext];
}

- (void)addSubtaskWithName:(NSString *)name subtaskLevel:(NSInteger)level atIndex:(NSInteger)indexValue parentTask:(TaskList *)parentTask {
    NSManagedObjectContext *context = [[CoreDataStack sharedInstance] managedObjectContext];
    TaskList *newTask = [NSEntityDescription insertNewObjectForEntityForName:@"TaskList" inManagedObjectContext:context];
    newTask.taskName = name;
    newTask.level = level;
    newTask.isCompleted = NO;
    newTask.parentTask = parentTask;
    newTask.hierarchicalNumber = [self generateHierarchicalNumberForParent:parentTask inContext:context];
    
    NSMutableSet *mutableSubtasks = [parentTask.subtask mutableCopy];
    [mutableSubtasks addObject:newTask];
    parentTask.subtask = [mutableSubtasks copy];
    
    [[CoreDataStack sharedInstance] saveContext];
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

@end
