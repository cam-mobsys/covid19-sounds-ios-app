//
//  QuestionnaireDaily+CoreDataProperties.swift
//  covid19-sounds
//
//  Authors:
//
//    Andreas Grammenos
//
//  Copyright © 2020 Computer Lab / Mobile Systems Group. All rights reserved.
//

import Foundation
import CoreData

/// The class which interfaces with `CoreData` for the `QuestionnaireDaily` object.
///
extension QuestionnaireDaily {

  /// The function that performs a fetch requests within `CoreData` to get the `QuestionnaireDaily` objects.
  ///
  /// - Returns: the `NSFetchRequest` parameterised for the `QuestionnaireDaily` objects.
  ///
  @nonobjc public class func fetchRequest() -> NSFetchRequest<QuestionnaireDaily> {
    return NSFetchRequest<QuestionnaireDaily>(entityName: "QuestionnaireDaily")
  }
  /// the breathe audio file
  @NSManaged public var audio_breathe: Data?
  /// the cough audio file
  @NSManaged public var audio_cough: Data?
  /// the read audio file
  @NSManaged public var audio_read: Data?
  /// the covid status
  @NSManaged public var covid: String?
  /// the date completed
  @NSManaged public var datetime: String?
  /// the location, if enabled.
  @NSManaged public var location: String?
  /// the symptom list.
  @NSManaged public var symptoms: String?
}
