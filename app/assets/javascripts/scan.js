function Line(ctx) {
    var me = this;
    
    this.x1 = 0;
    this.x2 = 0;
    this.y1 = 0;
    this.y2 = 0;
    
    this.draw = function() {
        oldstyle = ctx.strokeStyle;
        ctx.strokeStyle = '#a8a';
        ctx.beginPath();
        ctx.moveTo(me.x1, me.y1);
        ctx.lineTo(me.x2, me.y2);
        ctx.stroke();
        ctx.strokeStyle = oldstyle;
    }
}

