//
//  TaskOperations.m
//  ToDoListAppShared
//
//  Created by Tushar  Verma on 11.03.24.
//

#import "TaskOperations.h"

@implementation TaskOperations

-(instancetype)init{
//    [super init];
    self.allTasks = [[NSMutableArray alloc]init];
    self.dataArray = [[NSMutableArray alloc]init];
    
    return self;
}

- (NSMutableArray*)loadData{
    return _dataArray;
}


- (void)flattenTasks:(NSArray<TaskModel *> *)tasks {
    if (tasks) {
        
        NSMutableArray<TaskModel *> *existingData = [NSMutableArray arrayWithArray:[self loadDataFromPlist]];
        
        // Append new records to existing data
        [existingData addObjectsFromArray:tasks];
        
        // Define the file path where the plist will be saved
        NSString *plistFilePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject stringByAppendingPathComponent:@"TasksList.plist"];
        
        // Serialize the Task model data into a format that can be saved to a plist
        NSMutableArray<NSDictionary *> *serializedTasks = [NSMutableArray array];
        for (TaskModel *task in existingData) {
            NSDictionary *serializedTask = @{
                @"name": task.name,
                @"level": @(task.level),
                @"subtasks": [self serializeSubtasks:task.subtasks] // Assuming subtasks are TaskModel objects
            };
            [serializedTasks addObject:serializedTask];
        }
        
        // Write the serialized data to a plist file
        if (![serializedTasks writeToFile:plistFilePath atomically:YES]) {
            NSLog(@"Failed to save plist file.");
        } else {
            NSLog(@"Plist file saved successfully at path: %@", plistFilePath);
        }
    }
    else {
        NSLog(@"No data to save.");
    }
}

- (NSArray<TaskModel *> *)loadDataFromPlist {
    // Define the file path from where the plist will be loaded
    NSString *plistFilePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject stringByAppendingPathComponent:@"TasksList.plist"];
    
    // Load the data from the plist file
    NSArray<NSDictionary *> *serializedTasks = [NSArray arrayWithContentsOfFile:plistFilePath];
    
    // Deserialize the loaded data back into Task model objects
    NSMutableArray<TaskModel *> *dataArray = [NSMutableArray array];
    if (serializedTasks) {
        for (NSDictionary *serializedTask in serializedTasks) {
            NSString *name = serializedTask[@"name"];
            NSInteger level = [serializedTask[@"level"] integerValue];
            NSArray<TaskModel *> *subtasks = [self deserializeSubtasks:serializedTask[@"subtasks"]]; // Assuming subtasks are TaskModel objects
            TaskModel *task = [[TaskModel alloc] initWithName:name level:level subtasks:subtasks];
            [dataArray addObject:task];
        }
    } else {
        NSLog(@"Failed to load data from plist file.");
    }
    return [dataArray copy];
}

- (void)updateValueInPlist:(NSString *)key newValue:(NSString *)newValue atIndex:(NSInteger)index {
    // Get the file path of the plist
    NSString *plistFilePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject stringByAppendingPathComponent:@"TasksList.plist"];
    
    // Load the contents of the plist into an array
    NSMutableArray *plistArray = [NSMutableArray arrayWithContentsOfFile:plistFilePath];
    
    // Update the value associated with the specified key in the dictionary at the specified index
    if (plistArray && index < [plistArray count]) {
        NSMutableDictionary *dictToUpdate = [NSMutableDictionary dictionaryWithDictionary:[plistArray objectAtIndex:index]];
        [dictToUpdate setValue:newValue forKey:key];
        [plistArray replaceObjectAtIndex:index withObject:dictToUpdate];
        
        // Write the updated array back to the plist file
        if (![plistArray writeToFile:plistFilePath atomically:YES]) {
            NSLog(@"Failed to update plist file.");
        } else {
            NSLog(@"Plist file updated successfully at path: %@", plistFilePath);
        }
    } else {
        NSLog(@"Failed to load plist file or invalid index.");
    }
}


// Helper method to serialize subtasks
- (NSArray<NSDictionary *> *)serializeSubtasks:(NSArray<TaskModel *> *)subtasks {
    NSMutableArray<NSDictionary *> *serializedSubtasks = [NSMutableArray array];
    for (TaskModel *subtask in subtasks) {
        NSDictionary *serializedSubtask = @{
            @"name": subtask.name,
            @"level": @(subtask.level)
            // Add more properties if needed
        };
        [serializedSubtasks addObject:serializedSubtask];
    }
    return [serializedSubtasks copy];
}



// Helper method to deserialize subtasks
- (NSArray<TaskModel *> *)deserializeSubtasks:(NSArray<NSDictionary *> *)serializedSubtasks {
    NSMutableArray<TaskModel *> *subtasks = [NSMutableArray array];
    for (NSDictionary *serializedSubtask in serializedSubtasks) {
        NSString *name = serializedSubtask[@"name"];
        NSInteger level = [serializedSubtask[@"level"] integerValue];
        // Initialize TaskModel object using name, level, and other properties if needed
        TaskModel *subtask = [[TaskModel alloc] initWithName:name level:level subtasks:nil]; // Assuming subtasks are TaskModel objects
        [subtasks addObject:subtask];
    }
    return [subtasks copy];
}

@end
