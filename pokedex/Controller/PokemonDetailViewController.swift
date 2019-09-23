import UIKit

class PokemonDetailViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EvolutionUICollectionViewCell", for: indexPath) as? EvolutionUICollectionViewCell {
            let poke: Pokemon!
            poke = evolutionArray[indexPath.row]
            cell.configureCell(pokemon: poke)
            return cell
        } else {
            return UICollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        pokemon = evolutionArray[indexPath.row]
        self.viewDidLoad()
        self.viewWillAppear(true)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return evolutionArray.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 105, height: 105)
    }
    
    func configureNavigationBar() {
        navigationController?.navigationBar.barTintColor = .mainColor()
        navigationController?.navigationBar.barStyle = .black
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: nil, action: nil)
    }
    
    @IBOutlet weak var mainPokemonImage: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var defenseLabel: UILabel!
    @IBOutlet weak var heightLabel: UILabel!
    @IBOutlet weak var pokedexIdLabel: UILabel!
    @IBOutlet weak var weightLabel: UILabel!
    @IBOutlet weak var attackLabel: UILabel!
    @IBOutlet weak var evolutions: UICollectionView!
    @IBOutlet weak var evoLabel: UILabel!
    
    var evolutionArray = [Pokemon]()
    var pokemon: Pokemon!
    var pokemonDescript: Pokemon!
    var evoUrl: String = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        navigationItem.title = pokemon.name.capitalized
        let img = UIImage(named: "\(pokemon.pokedexId)")
        mainPokemonImage.image = img
        pokedexIdLabel.text = "\(pokemon.pokedexId)"
        evolutions.dataSource = self
        evolutions.delegate = self
        DispatchQueue.main.async{ [weak self] in
            self?.fetchPokemonJson{(res) in
                switch res {
                case .success(_):
                    self?.fetchPokemonDescriptionJson{(res) in
                        switch res {
                        case .success(_):
                            self?.fetchPokemonEvoData{(res) in
                                switch res {
                                case .success(_):
                                    self!.evolutions.reloadData()
                                case .failure(let error):
                                    print(error)
                                }
                            }
                        case .failure(let error):
                            print(error)
                        }
                    }
                case .failure(let error):
                    print(error)
                }
            }
        }
        self.evolutionArray.removeAll()
    }
    
    func fetchPokemonDescriptionJson(completion: @escaping (Result<Pokemon, Error>) -> Void) {
        let descriptionUrlString = "https://pokeapi.co/api/v2/pokemon-species/\(pokemon.pokedexId)"
        guard let descriptionUrl = URL(string: descriptionUrlString) else {return}
        URLSession.shared.dataTask(with: descriptionUrl) { (data, response, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            do {
                var pokemonDescript = try JSONDecoder().decode(Pokemon.self, from: data!)
                DispatchQueue.main.async { [weak self] in
                    for version in pokemonDescript.description! {
                        if version.version.name == "emerald", version.language.name == "en" {
                            self!.descriptionLabel.text = version.flavorText
                        } else if version.version.name == "ultra-sun" , version.language.name == "en" {
                            self!.descriptionLabel.text = version.flavorText
                        } else if version.version.name == "alpha-sapphire" , version.language.name == "en" {
                            self!.descriptionLabel.text = version.flavorText
                        }
                    }
                    self?.evoUrl = pokemonDescript.evolutionChainURL!.url
                    completion(.success(pokemonDescript))
                }
            } catch let jsonError {
                completion(.failure(jsonError))
            }
            }.resume()
    }
    
    func fetchPokemonJson(completion: @escaping (Result<Pokemon, Error>) -> Void) {
        let jsonUrlString = "https://pokeapi.co/api/v2/pokemon/\(pokemon.pokedexId)"
        guard let url = URL(string: jsonUrlString) else {return}
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            do {
                var pokemon = try JSONDecoder().decode(Pokemon.self, from: data!)
                DispatchQueue.main.async { [weak self] in
                    self?.weightLabel.text = "\(pokemon.weight!)"
                    self?.heightLabel.text = "\(pokemon.height!)"
                    for num in pokemon.stats! {
                        if num.stat.name == "attack" {
                            pokemon.attack = num.baseStat!
                            self?.attackLabel.text = "\(pokemon.attack!)"
                        }
                    }
                    for num in pokemon.stats! {
                        if num.stat.name == "defense" {
                            pokemon.defense = num.baseStat!
                            self?.defenseLabel.text = "\(pokemon.defense!)"
                        }
                    }
                    if pokemon.types!.count > 1 {
                        self?.typeLabel.text = "\(pokemon.types![0].type!.typeName!.capitalized) / \(pokemon.types![1].type!.typeName!.capitalized)"
                    } else {
                        self?.typeLabel.text = "\(pokemon.types![0].type!.typeName!.capitalized)"
                    }
                    completion(.success(pokemon))
                }
            } catch let jsonError {
                completion(.failure(jsonError))
            }
            }.resume()
    }
    
    func fetchPokemonEvoData (completion: @escaping (Result<Pokemon, Error>) -> Void) {
        let evoJsonString = evoUrl
        guard let evoUrl = URL(string: evoJsonString) else {return}
        URLSession.shared.dataTask(with: evoUrl) { (data, response, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            do {
                var pokemonEvo = try JSONDecoder().decode(Pokemon.self, from: data!)
                DispatchQueue.main.async { [weak self] in
                    if self?.pokemon.pokeName?.lowercased() == pokemonEvo.evolutionDetails!.species.name && (pokemonEvo.evolutionDetails?.evolvesTo!.isEmpty)! {
                        self?.evoLabel.text = "Next Evolution: None"
                    } else if self!.pokemon.pokeName?.lowercased() == pokemonEvo.evolutionDetails!.species.name && (pokemonEvo.evolutionDetails?.evolvesTo!.count)! == 1 {
                        self?.evoLabel.text = "Next Evolution: \(pokemonEvo.evolutionDetails!.evolvesTo![0].nextSpecies!.name!.capitalized)"
                        if let url = pokemonEvo.evolutionDetails!.evolvesTo![0].nextSpecies!.url {
                            let newStr = url.replacingOccurrences(of: "https://pokeapi.co/api/v2/pokemon-species/", with: "")
                            let newEvoId = newStr.replacingOccurrences(of: "/", with: "")
                            pokemonEvo.nextEvoId = newEvoId
                        }
                        let nextEvoPokemon = Pokemon(name: "\(pokemonEvo.evolutionDetails!.evolvesTo![0].nextSpecies!.name!)", pokedexId: Int(pokemonEvo.nextEvoId!)!)
                        self!.evolutionArray.append(nextEvoPokemon)
                    } else if self!.pokemon.pokeName?.lowercased() == pokemonEvo.evolutionDetails!.evolvesTo![0].nextSpecies!.name && (pokemonEvo.evolutionDetails?.evolvesTo![0].nextEvolvesTo!.count)! == 1 {
                        self?.evoLabel.text = "Next Evolution: \(pokemonEvo.evolutionDetails!.evolvesTo![0].nextEvolvesTo![0].nextSpecies!.name!.capitalized)"
                        if let url = pokemonEvo.evolutionDetails!.evolvesTo![0].nextEvolvesTo![0].nextSpecies!.url {
                            let newStr = url.replacingOccurrences(of: "https://pokeapi.co/api/v2/pokemon-species/", with: "")
                            let newEvoId = newStr.replacingOccurrences(of: "/", with: "")
                            pokemonEvo.nextEvoId = newEvoId
                        }
                        let nextEvoPokemon = Pokemon(name: "\(pokemonEvo.evolutionDetails!.evolvesTo![0].nextEvolvesTo![0].nextSpecies!.name!)", pokedexId: Int(pokemonEvo.nextEvoId!)!)
                        self!.evolutionArray.append(nextEvoPokemon)
                    } else if self!.pokemon.pokeName?.lowercased() == pokemonEvo.evolutionDetails!.species.name, (pokemonEvo.evolutionDetails?.evolvesTo!.count)! > 1 {
                        self?.evoLabel.text = "Next Evolution: Multiple Choices"
                        for each in 0..<(pokemonEvo.evolutionDetails!.evolvesTo!.count) {
                            if let url = pokemonEvo.evolutionDetails!.evolvesTo![each].nextSpecies!.url {
                                let newStr = url.replacingOccurrences(of: "https://pokeapi.co/api/v2/pokemon-species/", with: "")
                                let newEvoId = newStr.replacingOccurrences(of: "/", with: "")
                                pokemonEvo.nextEvoId = newEvoId
                            }
                            let nextEvoPokemon = Pokemon(name: "\(pokemonEvo.evolutionDetails!.evolvesTo![each].nextSpecies!.name!)", pokedexId: Int(pokemonEvo.nextEvoId!)!)
                            self!.evolutionArray.append(nextEvoPokemon)
                        }
                    } else if self!.pokemon.pokeName?.lowercased() == pokemonEvo.evolutionDetails!.evolvesTo![0].nextSpecies!.name, (pokemonEvo.evolutionDetails!.evolvesTo![0].nextEvolvesTo!.count) > 1 {
                        self?.evoLabel.text = "Next Evolution: Multiple Choices"
                        for each in 0..<(pokemonEvo.evolutionDetails!.evolvesTo![0].nextEvolvesTo!.count){
                            if let url = pokemonEvo.evolutionDetails!.evolvesTo![0].nextEvolvesTo![each].nextSpecies!.url {
                                let newStr = url.replacingOccurrences(of: "https://pokeapi.co/api/v2/pokemon-species/", with: "")
                                let newEvoId = newStr.replacingOccurrences(of: "/", with: "")
                                pokemonEvo.nextEvoId = newEvoId
                            }
                            let nextEvoPokemon = Pokemon(name: "\(pokemonEvo.evolutionDetails!.evolvesTo![0].nextEvolvesTo![each].nextSpecies!.name!)", pokedexId: Int(pokemonEvo.nextEvoId!)!)
                            self!.evolutionArray.append(nextEvoPokemon)
                        }
                    } else {
                        self?.evoLabel.text = "Next Evolution: None"
                    }
                    completion(.success(pokemonEvo))
                }
            } catch let jsonError {
                completion(.failure(jsonError))
            }
            }.resume()
    }
}

