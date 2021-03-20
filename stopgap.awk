func substitute(csv){
    if(length($1)==0){
        $1="Missing Summary"
    }
    return $0
}
BEGIN{OFS=","} {print substitute($0)}
