require 'person'

describe Person do
  context 'can translate cohort names to start dates' do
    context 'Mar 2015' do
      subject(:person) do 
        described_class.new(  
            name: 'Maciej Kurek',
            github_id: 'maciejk77',
            cohort: 'Mar 2015',
            first_offer_date: '2015-09-24',
            salary: '30000',
            company: 'Ensighten',
            currency: 'GBP',)
      end
      it 'is handled' do
        expect(person.start_date).to eq Date.parse('2015-03-16')
      end
    end
    context 'Ronin Mar 2015' do
      subject(:person) do 
        described_class.new(  
          name: 'Ilya Faybisovich',
          github_id: 'https://github.com/ilyafaybisovich/CV',
          cohort: 'Ronin Mar 2015',
          first_offer_date: '2015-08-27',
          salary: '20000',
          company: 'FNZ',
          currency: 'GBP')
      end
      it 'is handled' do
        expect(person.start_date).to eq Date.parse('2015-03-16')
      end
    end
    context 'Jul 2015' do
      subject(:person) do 
        described_class.new(  
          name: 'Retesh Bajaj',
          github_id: 'reteshbajaj',
          cohort: 'Jul 2015',
          first_offer_date: '',
          salary: '',
          company: '',
          currency: '')
      end
      it 'is handled' do
        expect(person.start_date).to eq Date.parse('2015-07-20')
      end
    end
  end
end
