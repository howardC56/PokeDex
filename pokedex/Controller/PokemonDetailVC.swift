//
//  PokemonDetailVC.swift
//  pokedex
//
//  Created by Howard Chang on 7/5/19.
//  Copyright © 2019 Howard Chang. All rights reserved.
//

import UIKit



class PokemonDetailVC: UIViewController {

    @IBOutlet weak var nameLbl: UILabel!
    
    @IBOutlet weak var mainImg: UIImageView!
    @IBOutlet weak var descriptionLbl: UILabel!
    @IBOutlet weak var typeLbl: UILabel!
    @IBOutlet weak var defenseLbl: UILabel!
    @IBOutlet weak var heightLbl: UILabel!
    @IBOutlet weak var pokedexIdLbl: UILabel!
    @IBOutlet weak var weightLbl: UILabel!
    @IBOutlet weak var attackLbl: UILabel!
    
    @IBOutlet weak var secondNextEvoImg: UIImageView!
    @IBOutlet weak var nextEvoImg: UIImageView!
    @IBOutlet weak var evoLbl: UILabel!
    
   
    
    var pokemon: Pokemon!
    var pokemonDescript: Pokemon!
    var evoUrl: String = ""
    override func viewDidLoad() {
        super.viewDidLoad()

        nameLbl.text = pokemon.name.capitalized
        let img = UIImage(named: "\(pokemon.pokedexId)")
        mainImg.image = img
        pokedexIdLbl.text = "\(pokemon.pokedexId)"
        DispatchQueue.main.async{
            [weak self] in
            self?.fetchPokemonJson{(res) in
                
                switch res {
                case .success(let pokemon):
                    print("y", pokemon)
                  
                case .failure(let err):
                    print("f", err)
                }
            }
            self?.fetchPokemonDescriptionJson{(res) in
                switch res {
                case.success(let pokemon):
                    print("yy")
                case .failure(let err):
                    print("ff")
                }
            }
        }
    }
 
    
        func fetchPokemonDescriptionJson(completion: @escaping (Result<Pokemon, Error>) -> Void) {
            let descriptionUrlString = "https://pokeapi.co/api/v2/pokemon-species/\(pokemon.pokedexId)"
            DispatchQueue.main.async {
                [weak self] in
                guard let descriptionUrl = URL(string: descriptionUrlString) else {return}
                URLSession.shared.dataTask(with: descriptionUrl) { (data, response, err) in
                    if let err = err {
                        completion(.failure(err))
                        return
                    }
                    do {
                        var pokemonDescript = try JSONDecoder().decode(Pokemon.self, from: data!)
                        DispatchQueue.main.async {
                            for version in pokemonDescript.description! {
                                if version.version.name == "emerald", version.language.name == "en" {
                                   
                                    self?.descriptionLbl.text = version.flavorText
                                } else if version.version.name == "ultra-sun" , version.language.name == "en" {
                                    self?.descriptionLbl.text = version.flavorText
                                } else if version.version.name == "alpha-sapphire" , version.language.name == "en" {
                                    self?.descriptionLbl.text = version.flavorText
                                }
                            }
                            self!.evoUrl = pokemonDescript.evolutionChainURL!.url
                            print(self!.evoUrl)
                            completion(.success(pokemonDescript))
                        }
                    } catch let jsonError {
                        completion(.failure(jsonError))
                    }
                }.resume()
            }
        }
    
    func fetchPokemonJson(completion: @escaping (Result<Pokemon, Error>) -> Void) {
        let jsonUrlString = "https://pokeapi.co/api/v2/pokemon/\(pokemon.pokedexId)"
        DispatchQueue.main.async{
          [weak self] in
        
        guard let url = URL(string: jsonUrlString) else {return}
        
        URLSession.shared.dataTask(with: url) { (data, response, err) in
            if let err = err {
                completion(.failure(err))
                return
            }
            
            do {
               
                var pokemon = try JSONDecoder().decode(Pokemon.self, from: data!)
                
                DispatchQueue.main.async { [weak self] in
                    self?.weightLbl.text = "\(pokemon.weight!)"
                    self?.heightLbl.text = "\(pokemon.height!)"
                    for num in pokemon.stats! {
                        if num.stat.name == "attack" {
                            pokemon.attack = num.baseStat!
                            self?.attackLbl.text = "\(pokemon.attack!)"
                        }
                        
                    }
                    for num in pokemon.stats! {
                        if num.stat.name == "defense" {
                            pokemon.defense = num.baseStat!
                            self?.defenseLbl.text = "\(pokemon.defense!)"
                        }
                    }
                    if pokemon.types!.count > 1 {
                       self?.typeLbl.text = "\(pokemon.types![0].type!.TypeName!.capitalized) / \(pokemon.types![1].type!.TypeName!.capitalized)"
                        
                    } else {
                        self?.typeLbl.text = "\(pokemon.types![0].type!.TypeName!.capitalized)"
                    }
                    
                    
                    completion(.success(pokemon))
                }
                } catch let jsonError {
                completion(.failure(jsonError))
            }
            }.resume()
    }
        }
    
    func fetchPokemonEvoData (completion: @escaping (Result<Pokemon, Error>) -> Void) {
        let evoJsonString = evoUrl
        DispatchQueue.main.async{
            [weak self] in
            
            guard let evoUrl = URL(string: evoJsonString) else {return}
            
            URLSession.shared.dataTask(with: evoUrl) { (data, response, err) in
                if let err = err {
                    completion(.failure(err))
                    return
                }
                
                do {
                    var pokemonEvo = try JSONDecoder().decode(Pokemon.self, from: data!)
                    
                    DispatchQueue.main.async { [weak self] in
                        if pokemonEvo.pokeName == pokemonEvo.evolutionDetails!.species.name {
                            
                        }
                        
                    }
                } catch let jsonError {
                    completion(.failure(jsonError))
                }
    }.resume()
    }
    }


    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
}
