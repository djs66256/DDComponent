// MIT License
//
// Copyright (c) 2016 Daniel (djs66256@163.com)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import UIKit
import DDComponent

class SimpleViewController: UICollectionViewController {
    
    let models = [
        TitleModel(title: "2009年纽约州第二十国会选区特别选举于2009年3月31日举行，旨在为纽约州第二十国会选区选派联邦众议员，填补前任议员陆天娜于2009年1月出任联邦参议员后出现的席位空缺。该州联邦参议员希拉里·罗德姆·克林顿此前接受总统贝拉克·奥巴马提名出任国务卿一职，州长大卫·帕特森任命陆天娜填补空缺。参选的两大党派候选人分别是民主党人、私营商户斯科特·墨菲，以及共和党人、纽约州众议院少数党领袖吉姆·泰迪斯科。第二十国会选区历来倾于保守，竞选早期的民调表明泰迪斯科胜算较大，但到了2009年2月，选举已是胜负难料。共和党将这场选举视为对总统奥巴马经济政策的全民公决，因此为泰迪斯科的竞选注入重资，还出动多位知名共和党政治领袖——如前联邦众议院议长纽特·金里奇、国会少数党领袖约翰·博纳、以及前纽约州州长乔治·保陶基为候选人摇旗呐喊。民主党则以总统奥巴马、副总统乔·拜登，以及联邦参议员陆天娜的支持来应战。选举结果非常接近，领先位置几度易主，难解难分，甚至一度出现两位候选人各得7万7225票的平局。最终打破僵局的是缺席投票。泰迪斯科起初有小幅领先，但到了4月10日，领先位置已由墨菲占据，4月23日时，墨菲的领先优势已有401票，泰迪斯科于是在次日承认落败，墨菲于4月29日宣誓就职。媒体报道认为，民主党在2008年11月的胜利，以及墨菲对经济刺激计划的明确支持，都是他赢得这场特别选举的重要原因。", controllerClass: nil),
        TitleModel(title: "Macrotarsomys petteri, Petter's big-footed mouse, is a Malagasy rodent. It is the largest in its genus, with a head and body length of 150 mm (5.9 in) and body mass of 105 g (3.7 oz). The upperparts are brown, darkest in the middle of the back, and the underparts are white to yellowish. The animal has long whiskers, short forelimbs, and long hindfeet. The tail ends in a prominent tuft of long, light hairs. The skull is robust and the molars are low-crowned and cuspidate. The species most resembles, and may be most closely related to, the greater big-footed mouse. The specific name, petteri, honors French zoologist François Petter for his contributions to the study of Malagasy rodents. M. petteri is now found only in southwestern Madagascar's Mikea Forest, which is threatened by human development. Subfossil records indicate that it used to be more widely distributed in southern Madagascar; climatic changes and competition with introduced species may have led to the shift in its distribution. (Full article...)", controllerClass: nil),
        TitleModel(title: "On 8 June 2017, the United Kingdom general election of 2017 took place, which resulted in the Conservative Party losing its parliamentary majority. The 650 parliamentary constituencies each elected one Member of Parliament (MP) to the House of Commons, otherwise known as the lower house of Parliament. Under the terms of the Fixed-term Parliaments Act 2011, an election had not been due until 7 May 2020. However, on 19 April 2017 a snap election, called by Prime Minister Theresa May, was passed by a 522-to-13 vote in the House of Commons.", controllerClass: nil),
        TitleModel(title: "The Conservative Party, (governing since 2010 as a senior coalition partner prior to 2015 and as a majority government thereafter) was defending a majority of 12, against the Labour Party. The official opposition is led by Jeremy Corbyn. In order to \"strengthen [her] hand in forthcoming Brexit negotiations,\"[1] May hoped to secure a larger Parliamentary majority for the Conservative Party.", controllerClass: nil),
        TitleModel(title: "Since the previous general election, opinion polls had shown public opinion consistently increase for the Conservatives over Labour. At the beginning of the campaign, the Conservative Party had a 20-point lead, and peaked by 25 points in the early weeks of canvassing. This triggered widespread expectations of a landslide victory, similar to that of 1983 United Kingdom general election. However, in the latter stages of the campaign, their lead began to diminish as Labour Party support surged in the final weeks. Despite the narrowing opinion polls, the election results still came as a surprise for major political commentators.", controllerClass: nil),
        TitleModel(title: "Following the election results, the Conservatives spoke with Democratic Unionist Party (DUP) of Northern Ireland, whose 10 seats could allow for the formation of a minority Conservative government.[2]", controllerClass: nil),
        TitleModel(title: "Although the Labour Party only secured second place, Labour won its greatest share of the popular vote since 2001, and for the first time since 1997, gained more seats than it lost. Additionally the party secured a positive swing of 9.6%, the largest swing for an opposition party since Clement Attlee led Labour to win a large majority in 1945. However, the Conservative Party also gained an unusually high share of public support, winning its highest vote share since 1983 and obtaining a higher number of individual votes than any party since 1992. The result may represent a shift back towards two-party politics in the country, ending a prolonged gradual trend in the opposite direction.", controllerClass: nil),
        TitleModel(title: "The third-largest party, the Scottish National Party (SNP), had won 56 of the 59 Scottish constituencies in 2015, but returned with 21 fewer seats. Twelve of these seats went to the Conservatives, in a reversal of a general trend in other parts of the UK. It was suggested part of the reason was a backlash against the SNP's calls for Scottish independence and tactical voting for the unionist parties.[3][4] The Liberal Democrats won several seats from the Conservatives and Scottish National Party, but also lost seats, with an overall increase of three. In Northern Ireland, the Democratic Unionist Party and Sinn Féin both gained additional seats, capturing all the seats won at the last election by the Ulster Unionist Party (UUP) and the Social Democratic and Labour Party (SDLP). Support for the UK Independence Party, which enjoyed a significant portion of the popular vote in 2015, was largely wiped out.[5] The Green Party maintained its single seat, and there was one independent MP elected (for the Northern Ireland constituency of North Down).", controllerClass: nil),
        TitleModel(title: "The election campaign was interrupted by two major terrorist attacks, in Manchester and London, with national security becoming a prominent issue during the latter weeks. Negotiation positions following the UK's invocation of Article 50 of the Treaty on European Union in March 2017 to leave the EU also featured significantly in the campaign, as did the regular major issues of the economy, education, jobs and the National Health Service.", controllerClass: nil),
        TitleModel(title: "2009年纽约州第二十国会选区特别选举于2009年3月31日举行，旨在为纽约州第二十国会选区选派联邦众议员，填补前任议员陆天娜于2009年1月出任联邦参议员后出现的席位空缺。该州联邦参议员希拉里·罗德姆·克林顿此前接受总统贝拉克·奥巴马提名出任国务卿一职，州长大卫·帕特森任命陆天娜填补空缺。参选的两大党派候选人分别是民主党人、私营商户斯科特·墨菲，以及共和党人、纽约州众议院少数党领袖吉姆·泰迪斯科。此外，自由党人埃里克·桑德沃尔起初以第三党候选人身份参选，但没能进入最后的较量。", controllerClass: nil),
        TitleModel(title: "第二十国会选区历来倾于保守，竞选早期的民调表明泰迪斯科胜算较大，但到了2009年2月，选举已是胜负难料。共和党将这场选举视为对总统奥巴马经济政策的全民公决，因此为泰迪斯科的竞选注入重资，还出动多位知名共和党政治领袖——如前联邦众议院议长纽特·金里奇、国会少数党领袖约翰·博纳、以及前纽约州州长乔治·保陶基为候选人摇旗呐喊。民主党则以总统奥巴马、副总统乔·拜登，以及联邦参议员陆天娜的支持来应战。", controllerClass: nil),
        TitleModel(title: "竞选期间出现的主要议题包括：各候选人对总统奥巴马经济刺激计划的立场，泰迪斯科直到竞选后期才对此表态反对，墨菲则表示支持。泰迪批评这一经济刺激计划是美国国际集团巨额奖金丑闻爆发的潜在因素，他的竞选团队还指称墨菲在20世纪90年代创办公司时没有依法纳税。墨菲则经常以泰迪斯科的主要住所并不在第二十国会选区内来展开进攻。", controllerClass: nil),
        TitleModel(title: "选举结果非常接近，领先位置几度易主，难解难分，甚至一度出现两位候选人各得7万7225票的平局。最终打破僵局的是缺席投票，经联邦司法部起诉后，缺席投票的接收有效期延至4月13日。泰迪斯科起初有小幅领先，但到了4月10日，领先位置已由墨菲占据，4月23日时，墨菲的领先优势已有401票，泰迪斯科于是在次日承认落败，墨菲于4月29日宣誓就职。媒体报道认为，民主党在2008年11月的胜利，以及墨菲对经济刺激计划的明确支持，都是他赢得这场特别选举的重要原因。", controllerClass: nil)
        ]
    
    lazy var rootComponent: DDCollectionViewRootComponent = {
        let root = DDCollectionViewRootComponent(collectionView: self.collectionView!, bind:true)
        return root
    }()

    init() {
        super.init(collectionViewLayout: UICollectionViewFlowLayout())
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView?.backgroundColor = UIColor.white

        let texts = TextsComponent()
        texts.navigationController = self.navigationController
        texts.cellModels = self.models
        self.rootComponent.subComponents = [texts]
        self.collectionView?.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
