//: Playground - noun: a place where people can play

import Cocoa

typealias WCLListSourceUpdaterResult = (addedIndexPaths : [NSIndexPath], removedIndexPaths: [NSIndexPath], movedIndexPaths : [(fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath)])

func compareResults(oldArr : [NSObject], newArr : [NSObject]) -> WCLListSourceUpdaterResult{
    
    let removed = Set(oldArr).subtract(Set(newArr))
    let added = Set(newArr).subtract(Set(oldArr))
    let sameItems = Set(oldArr).intersect(newArr)
    
    
    var addedIndexPaths : [NSIndexPath] = []
    var removedIndexPaths : [NSIndexPath] = []
    var movedIndexPaths : [(fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath)] = []
        
    for item in removed {
        if let ind = oldArr.indexOf(item) {
                removedIndexPaths.append(NSIndexPath(forItem: ind, inSection: 0))
            }
        }
        for item in added {
            if let ind = newArr.indexOf(item) {
                addedIndexPaths.append(NSIndexPath(forItem: ind, inSection: 0))
            }
        }
        for item in sameItems {
            if let oldIndex = oldArr.indexOf(item), let newIndex = newArr.indexOf(item) where oldIndex != newIndex {
                let x : (fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) = (NSIndexPath(forItem: oldIndex, inSection: 0), NSIndexPath(forItem: newIndex, inSection: 0))
                movedIndexPaths.append(x)
            }
        }
        
    let results : WCLListSourceUpdaterResult = (addedIndexPaths, removedIndexPaths, movedIndexPaths)
    return results
}

let arr1 = [1,3,4,5,6]
let arr2 = [1,2,"A",6]

let result = compareResults(arr1, newArr: arr2)
for added in result.addedIndexPaths {
    print("added to indexPath", added.item)
}
for removed in result.removedIndexPaths {
    print("remove from indexPath", removed.item)
}