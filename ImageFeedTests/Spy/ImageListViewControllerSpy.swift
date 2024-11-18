import Foundation
@testable import Image_Feed

final class ImagesListViewControllerSpy: ImagesListViewControllerProtocol {
    var updateTableViewAnimatedCalled = false
    var reloadCellCalled = false
    var updatedOldCount: Int?
    var updatedNewCount: Int?
    var reloadedCellIndex: Int?

    func updateTableViewAnimated(oldCount: Int, newCount: Int) {
        updateTableViewAnimatedCalled = true
        updatedOldCount = oldCount
        updatedNewCount = newCount
    }

    func reloadCell(at index: Int) {
        reloadCellCalled = true
        reloadedCellIndex = index
    }
}
