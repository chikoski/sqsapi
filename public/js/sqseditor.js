(function(global, $){
    var editor = global.editor || {};
    var console = global.console;
    var running = null;

    var model = {};
    var view = {};

    model.SQSPhrasingContent = function(text){
	this.text = text;
    };
    
    model.SQSPhrasingContent.prototype = {};

    model.SQSBoxContent = function(){
	this.children = [];
    };
    model.SQSBoxContent.prototype = (function(){
	return {
	    add: function(child){
		console.log(child);
		if(child instanceof model.SQSPhrasingContent ||
		   child instanceof model.SQSBoxContent){
		    this.children.push(child);
		}
	    },
	    removeAt: function(child){
		if(this.children[child] != null){
		    this.children[child] = null;
		}
	    }
	};
    })();

    /*
     * BoxContent elements
     */
    model.Sheet = function(title){
	model.SQSBoxContent.call(this, arguments);
	this.title = title;
    };
    model.Sheet.prototype = (function(){
	return new model.SQSBoxContent();
    })();
    
    var SelectOne = function(){
	model.SQSBoxContent.call(this, arguments);
	this.title = null;
    };
    SelectOne.prototype = (function(){
	var proto = new model.SQSBoxContent();
	var super_add = proto.add;
	proto.add = function(elm){
	    if(elm instanceof model.Item){
		super_add(elm);
	    }
	};
	return proto;
    })();

    
    /*
     * PhrasingContent elements
     */
    model.Paragraph = function(text){
	model.SQSPhrasingContent.call(this, arguments);
    };
    model.Paragraph.prototype = (function(){
	return new model.SQSPhrasingContent();
    })();

    model.Hint = function(text){
	model.SQSPhrasingContent.call(this, arguments);
    };
    model.Hint.prototype = (function(){
	return new model.SQSPhrasingContent();
    })();

    model.Label = function(text){
	model.SQSPhrasingContent.call(this, arguments);
    };
    model.Label.prototype = (function(){
	return new model.SQSPhrasingContent();
    })();

    model.TextArea = function(text){
	model.SQSPhrasingContent.call(this, arguments);
	this.title = null;
    };
    model.TextArea.prototype = (function(){
	return new model.SQSPhrasingContent();
    })();

    /*
     * MatrixArray
     */
    model.MatrixForm = function(){
	this.rows = [];
	this.columns = [];
    };
    model.MatrixForm.prototype = (function(){
	return {
	    addRow: function(hint){
		if(hint instanceof model.Hint){
		    this.rows.push(hint);
		}
	    },
	    removeRow: function(hint){
	    },
	    removeRowAt: function(i){
		this.rows =
		    this.rows.slice(0, i).concat(this.rows.slice(i+1, this.rows.length));
	    },
	    addColumn: function(select){
		if(select instanceof model.SelectOne){
		    this.columns.push(select);
		}
	    },
	    removeRow: function(select){
	    },
	    removeRowAt: function(i){
		this.columns =
		    this.columns.slice(0, i).concat(this.columns.slice(i+1,
								       this.columns.length));
	    }
	    
	};
    })();

    var Parser = function(){
	this.product = null;
    };
    Parser.prototype = (function(){

	var selectOne = function(elm){
	};

	var matrixForm = function(elm){
	};

	var hint = function(){
	    return new model.Hint(this.text());
	};

	var label = function(){
	    return new model.Label(this.text());
	};
	
	var paragraph = function(){
	    return new model.Paragraph(this.text());
	};

	var textarea = function(){
	    var ret = new model.TextArea(this.text());
	};

	var tagnameOf = function(elm){
	    return elm.get(0).tagName.toLowerCase();
	};

	var table = {
	    "xforms:select1": selectOne,
	    "sqs:matrix-forms": matrixForm,
	    "xforms:hint": hint,
	    "xforms:label": label,
	    "p": paragraph,
	    "xforms:textarea": textarea
	};

	var doParse = function(elm, parent){
	    var tag = tagnameOf(elm);
	    var func = table[tag];
	    var ret = null;
	    if(func != null){
		ret = func.call(elm);
	    }
	    elm.children().each(function(){
		doParse($(this), ret || parent);
	    });
	    if(parent != null && parent.add != null){
		parent.add(ret);
	    }
	    return ret;
	};
	
	return {
	    parse: function(sqs){
		var self = this;
		self.product = new model.Sheet();

		$(sqs).children().each(function(elm){
		    doParse($(this), self.product);
		});
		
		return self.product;
	    }
	};
    })();

    var Editor = function(baseElement, sqs){
//	this.baseElement = $("#sheet").tmpl().appendTo(baseElement);
	this.sheet = null;
	if(sqs != null){
	    var parser = new Parser();
	    this.sheet = parser.parse(sqs);
	}
	this.templates = {};
    };
    Editor.prototype = (function(){

	var parseForms = function(elm){
	    var ret = [];
	    elm.each(function(){
		var form = $(this);
	    });
	    return ret;
	};
	var tagnameOf = function(elm){
	    var tagname = elm.tagName.toLowerCase();
	    var ret = tagname.split(':');
	    return ret[ret.length - 1];
	};

	var doRender = function(self, element, to){
	    if(!(element instanceof $)){
		element = $(element);
	    }
	    var rendered = self.createElementFrom(element);
	    element.children().each(function(){
		doRender(self, this, rendered);
	    });
	    if(to instanceof $){
		to.append(rendered);
	    }
	};

	return {
	    render: function(){
		var self = this;
		this.baseElement.empty();
		this.sqs.body.children().each(function(){
		    doRender(self, this, self.baseElement);
		});
	    },
	    parseSQS: function(document){
		this.sqs = new SQS(document);
	    },
	    createElementFrom: function(element){
		if(element instanceof $){
		    element = element.get(0);
		}
		var template = this.getTemplateFor(element);
		var ret = null;
		if(template != null){
		    var txt = $(element).text().replace(/^\s+/, "");
		    ret = template.tmpl({text: txt});
		}
		return ret;
	    },
	    getTemplateFor: function(element){
		var tagname = tagnameOf(element);
		if(this.templates[tagname] == null){
		    this.templates[tagname] = $("#" + tagname);
		}
		return this.templates[tagname];
	    }
	};
    })();

    var SQS = function(document){
	if(!(document instanceof $)){
	    document = $(document);
	}
	this.document = document;
	this.references = {};
	this.title(document.find("h"));
	this.textarea(document.find("xforms:textarea"));
	this.body = this.document.find("body").eq(0);
	this.header = this.document.find("header").eq(0);
    };
    
    SQS.prototype = {
	title: function(elm){
	    if(elm instanceof $){
		this.references.title = elm.eq(0);
	    }
	    return this.references.title;
	},
	forms: function(formlist){
	    if(typeof formlist === "array"){
		this.references.forms = formlist;
	    }
	    return formlist;
	},
	textarea: function(elm){
	    if(elm instanceof $){
		this.references.textarea = elm.eq(0);
	    }
	    if(elm == null){
		this.references.textarea = elm;
	    }
	    return this.references.textarea;
	},
	each: function(func){
	    this.document.each(func);
	}
    };

    var log = function(msg){
	if(console && console.log){
	    console.log(msg);
	}
    };

    var createEditor = function(baseElement, src, options){
	$.ajax({
	    url: src,
	    type: "get",
	    dataType: "xml",
	    success: function(sqs){
		if(sqs){
		    running = new Editor(baseElement, sqs);
//		    running.render();
		    if(typeof options.onload === "function"){
			options.onload(sqs);
		    }
		}
	    }
	});
    };

    editor.boot = function(baseElement, options){
	if(options == null){
	    options = {};
	}
	var sqsFiles = $('[type="text/x-sqs"]');
	if(sqsFiles.length){
	    var src = $(sqsFiles.get(0)).attr("src");
	    if(src){
		createEditor(baseElement, src, options);
	    }
	}
    };

    global.sqseditor = editor;
})(window, jQuery) ;