//
//  PokeCell.swift
//  pokedex
//
//  Created by Howard Chang on 6/27/19.
//  Copyright © 2019 Howard Chang. All rights reserved.

import UIKit

class PokeCell: UICollectionViewCell {
   
    @IBOutlet weak var thumbImg : UIImageView!
    @IBOutlet weak var nameLbl : UILabel!
    
    var pokemon: Pokemon!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        layer.cornerRadius = 5.0
        
        
    }
    
    
    func configureCell(pokemon: Pokemon) {
        self.pokemon = pokemon
        nameLbl.text = self.pokemon.name.capitalized
        thumbImg.image = UIImage(named: "\(self.pokemon.pokedexId)")
    }
    
}
