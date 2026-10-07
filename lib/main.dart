import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BMI',
      theme: ThemeData(

         primarySwatch: Colors.blue
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super (key: key);


  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  var wtController = TextEditingController();
  var ftController = TextEditingController();
  var inController = TextEditingController();

  var result = "";


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(

        ),
        body: Center(
          child: Container(
            width: 300,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
              Text('BMI',style: TextStyle(fontSize: 40,fontWeight:  FontWeight.w700),),
              SizedBox(height: 21,),
              TextField(
                controller:wtController,
                decoration: InputDecoration(
                  label: Text('Enter Your  weight(in Kgs)'),
                  prefixIcon: Icon(Icons.line_weight)
                ),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 12,),
              TextField(
                controller:ftController,
                decoration: InputDecoration(
                    label: Text('Enter Your  Height(in Feet)'),
                    prefixIcon: Icon(Icons.height)
                ),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 12,),
              TextField(
                controller:inController,
                decoration: InputDecoration(
                    label: Text('Enter Your  Height(in Inches)'),
                    prefixIcon: Icon(Icons.height)
                ),
                keyboardType: TextInputType.number,
              ),
                SizedBox(height: 12,),
                ElevatedButton(onPressed: (){
                  var wt = wtController.text.toString();
                  var ft = ftController.text.toString();
                  var inch = inController.text.toString();
                  if(wt!="" && ft!="" && inch!=""){
                    //BMI calculation
                    var iwt = int.parse(wt);
                    var ift = int.parse(ft);
                    var iInch = int.parse(inch);

                    var tInch = (ift*12)+iInch ;
                    var tCm = tInch*2.54;
                    var tM = tCm/100;
                    var bmi = iwt/(tM*tM);
                    setState(() {
                      result = "Your BMI is ${bmi.toStringAsFixed(2)}";
                    });


                  }else{
                    setState(() {
                      result = "Please fill all the required blanks";
                    });

                  }
                }, child: Text('Calculate')),
                SizedBox(height: 12,),
                Text(result,style: TextStyle(fontSize: 20,fontWeight: FontWeight.w500),),

            ],
          ),
        )

        )
    );
  }
}

