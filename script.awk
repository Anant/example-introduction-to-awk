func substitute(lyrics){
   for(i=0;i<=NF;i++){
       if($i=="Thundercats"){
            $i="Lightningcats"
       }
       else if($i=="Thundercats!"){
            $i="Lightningcats!"
       }
   } 
   return NR"." " " $0
}

{print substitute($0)}