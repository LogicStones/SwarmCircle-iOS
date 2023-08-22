//
//  ArrayWrapper.swift
//  Swarm Circle
//
//  Created by Rehan Khan's iMac on 09/09/2022.
//

import Foundation

class ArrayWrapper<T> {
  var array: [T]
  init(array: [T]) {
    self.array = array
  }
}


class ValueWrapper<T> {
  var value: T
  init(value: T) {
    self.value = value
  }
}
