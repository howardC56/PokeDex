import UIKit

class EvolutionUICollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var EvolutionImage: UIImageView!
    @IBOutlet weak var EvolutionName: UILabel!
    
    var pokemon: Pokemon!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        layer.cornerRadius = 5.0
    }
    
    func configureCell(pokemon: Pokemon) {
        self.pokemon = pokemon
        EvolutionName.text = self.pokemon.name.capitalized
        EvolutionImage.image = UIImage(named: "\(self.pokemon.pokedexId)")
    }
}
