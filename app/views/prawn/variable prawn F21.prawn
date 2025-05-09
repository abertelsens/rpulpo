cm = 30
pdf.font_families.update("minion" => {
    :normal => "app/assets/MinionPro-Regular.otf",
    :bold => "app/assets/MinionPro-Bold.otf",
    :italic => "app/assets/MinionPro-It.otf",
    :bold_italic => "app/assets/MinionPro-BoldIt.otf",
  })

  pdf.font_families.update("minionSC" => {
    :normal => "app/assets/MinionSC.otf",
  })

pdf.font "minion"


@people.each_with_index do |person,index|
pdf.move_down(30)
pdf.text 'PROFESSIO FIDEI', align: :center, size: 15 #, style: :bold


pdf.move_down(60)

pdf.text("Ego #{person.first_name} #{person.family_name} firma fide credo et profíteor ómnia et síngula quae continéntur\
in Symbolo fídei, vidélicet:

Credo in unum Deum Patrem omnipoténtem, factórem coeli et terrae, visibilium ómnium et invisibílium et in unum Dóminum \
Iesum Christum, Fílium Dei unigénitum, et ex Patre natum ante ómnia saécula, Deum de Deo, lumen de lúmine, Deum verum \
de Deo vero, génitum non factum, consubstantiálem Patri per quem ómnia facta sunt, qui propter nos hómines et propter \
nostram salútem descéndit de coelis, et incarnátus est de Spíritu Sancto, ex María Vírgine, et homo factus est; \
crucifixus etiam pro nobis sub Póntio Piláto, passus et sepúltus est; et resurréxit tértia die secúndum Scriptúras, \
et ascéndit in coelum, sedet ad déxteram Patris, et íterum venturus est cum glória iudicáre vivos et mórtuos, cuius \
regni non erit finis; et in Spíritum Sanctum Dóminum et vivificántem, qui ex Patre Filióque procédit; qui cum Patre et \
Fílio simul adorátur et conglorificátur qui locútus est per Prophétas; et unam sanctam cathólicam et apostólicam \
Ecclésiam.  Confíteor unum baptísma in remissiónem peccatórum, et exspécto resurrectiónem mortuórum, et vitam ventúri  \
saéculi. Amen.

Firma fide quoque credo ea ómnia quae in verbo Dei scripto vel trádito continentur et ab Ecclésia sive sollémni iudício \
sive ordinário et universáli Magistério tamquam divínitus reveláta credénda proponúntur.

Fírmiter etiam ampléctor ac retíneo ómnia et síngula quae circa doctrínam de fide vel móribus ab eádem definitíve \
proponuntur.

Insuper religióso voluntátis et intelléctus obséquio doctrínis adhaéreo quas sive Románus Póntifex sive Collégium \
episcopórum enuntiant cum Magistérium authenticum exércent etsi non definitívo actu eásdem proclamáre inténdant.",
indent_paragraphs: 30, align: :justify, size: 12
)


pdf.canvas do
  pdf.bounding_box([pdf.bounds.left+1*cm,pdf.bounds.bottom+1*cm+9], width: 200, height: 90) do
    pdf.text "pulpo.impreso", size: 9
  end
end

pdf.canvas do
  pdf.bounding_box([pdf.bounds.left+1*cm,pdf.bounds.top-1*cm], width: 400, height: 90) do
    pdf.text "COLLEGIUM  ROMANUM  SANCTAE  CRUCIS", size: 16, character_spacing: -0.7
  end
end

pdf.start_new_page if index+1<@people.size
end
