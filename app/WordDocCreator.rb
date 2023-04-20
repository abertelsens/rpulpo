require 'caracal'

class WordDocCreator
    
    def initialize()
    end

    def self.F28(settings)
        docx = Caracal::Document.save(settings[:path]) do |docx|
            
            docx.page_margins do 
                left    2267     # sets the left margin. units in twips.
                right   2267     # sets the right margin. units in twips.
                top     2267    # sets the top margin. units in twips.
                bottom  2267    # sets the bottom margin. units in twips.
            end

            docx.style do
                id              'Heading1'      # sets the internal identifier for the style.
                name            'Heading1'      # sets the internal identifier for the style.
                font            'Book Antiqua' # sets the font family.
                size            28              # sets the font size. units in half points.
                top             600           # sets the spacing below the paragraph. units in twips.
                bottom          1600           # sets the spacing below the paragraph. units in twips.
                indent_left     360         # sets the left indent. units in twips.
                indent_right    360         # sets the rights indent. units in twips.
                align           :center       # sets the alignment. accepts :left, :center, :right, and :both.
            end
            docx.style do
                id              'Normal'      # sets the internal identifier for the style.
                name            'Normal'      # sets the internal identifier for the style.
                font            'Book Antiqua' # sets the font family.
                size            22              # sets the font size. units in half points.
                top             150           # sets the spacing below the paragraph. units in twips.
                bottom          150           # sets the spacing below the paragraph. units in twips.
                line            280
                indent_first    360         # sets the left indent. units in twips.
                align           :both       # sets the alignment. accepts :left, :center, :right, and :both.
            end
            settings[:people].each_with_index do |person, index|

                docx.h1 'IUISUIURANDUM FIDELITATIS IN SUSCIPIEDO OFFICIO NOMINE ECCLESIAE EXERCENDO'
                docx.p "Ego #{person.first_name} #{person.family_name} in suscipiendo officio promitto me cum catholica Ecclesia communionem semper servaturum, sive verbis a me prolatis, sive mea agendi ratione." 
                docx.p "Magna cum diligentia et fidelitate onera explebo quibus teneor erga Ecclesiam, tum universam, tum particularem, in qua ad meum servitium, secundum iuris praescripta, exercendum vocatus sum."
                docx.p "In munere meo adimplendo, quod Ecclesiae nomine mihi commissum est, fidei depositum integrum servabo, fideliter tradam et illustrabo; quascumque igitur doctrinas iisdem contrarias devitabo."
                docx.p "Disciplinam cunctae Ecclesiae communem sequar et fovebo observantiamque cunctarum legum ecclesiasticarum, earum imprimis quae in Codice Iuris Canonici continentur, servabo."
                docx.p "Christiana oboedientia prosequar quae sacri Pastores, tamquam authentici fidei doctores et magistri declarant aut tamquam Ecclesiae rectores statuunt, atque Episcopis dioecesanis fideliter auxilium dabo, ut actio apostolica, nomine et mandato Ecclesiae exercenda, in eiusdem Ecclesiae communione peragatur."
                docx.p "Sic me Deus adiuvet et sancta Dei Evangelia, quae manibus meis tango."
                docx.page if index+1<settings[:people].size
            end
        end
        return File.new(settings[:path])
    end
    
end
 