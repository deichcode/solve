//
//  MainViewController.swift
//  powerStoryboard
//
//  Created by Sören Schröder on 11.01.20.
//  Copyright © 2020 Sören Schröder. All rights reserved.
//

func show(user: User) {
    guard let vc = storyboard?.instantiateViewController(identifier: "EditUser", creator: { coder in
        return EditUserViewController(coder: coder, selectedUser: user)
    }) else {
        fatalError("Failed to load EditUserViewController from storyboard.")
    }

    navigationController?.pushViewController(vc, animated: true)
}
