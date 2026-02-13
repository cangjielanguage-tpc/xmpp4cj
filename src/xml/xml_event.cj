/**
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package cangjie_tpc::xmpp4cj.xml

enum XmlEvent <: Equatable<XmlEvent> & ToString {
    | Decl
    | Comment
    | ProcInst
    | DTD
    | ElementStart
    | ElementEnd
    | Attribute
    | Namespace
    | Text
    | CData
    | EntityRef

    public operator func ==(other: XmlEvent): Bool {
        this.toString() == other.toString()
    }

    public override func toString(): String {
        return match (this) {
            case Decl => "Decl"
            case Comment => "Comment"
            case ProcInst => "ProcInst"
            case DTD => "DTD"
            case ElementStart => "ElementStart"
            case ElementEnd => "ElementEnd"
            case Attribute => "Attribute"
            case Namespace => "Namespace"
            case Text => "Text"
            case CData => "CData"
            case EntityRef => "EntityRef"
        }
    }

    func isCharacter(): Bool {
        match (this) {
            case Text | CData | EntityRef => true
            case _ => false
        }
    }
}

class DocTypeDecl {
    public init(name: String) {
        this(name, None, None)
    }
    public init(name: String, data: String) {
        this(name, data, None)
    }
    public init(name: String, entitiDecls: Array<EntityDecl>) {
        this(name, None, entitiDecls)
    }
    private DocTypeDecl(private let _name: String, private var _data: ?String,
        private var _entityDecls: ?Array<EntityDecl>) {}

    public prop name: String {
        get() {
            _name
        }
    }
    public prop data: ?String {
        get() {
            _data
        }
    }
    public prop entityDecls: ?Array<EntityDecl> {
        get() {
            _entityDecls
        }
    }
}

class EntityDecl {
    public EntityDecl(private let _name: String, private let _value: String) {}

    public prop name: String {
        get() {
            _name
        }
    }
    public prop value: String {
        get() {
            _value
        }
    }
}

class EntityReference {
    public EntityReference(private let _name: String, private let _decl: EntityDecl) {}

    public prop name: String {
        get() {
            _name
        }
    }
    public prop decl: EntityDecl {
        get() {
            _decl
        }
    }
}

class Attribute {
    public Attribute(private let _qname: QName, private let _value: String) {}

    public prop qname: QName {
        get() {
            _qname
        }
    }
    public prop value: String {
        get() {
            _value
        }
    }
}

class Namespace {
    public func getNamespace(_: String): ?String {
        return None
    }

    public func getFirstPrefix(_: String): ?String {
        return None
    }

    public func getPrefix(_: String): ?Array<String> {
        return None
    }

    public func getAll(): ?Array<(String, String)> {
        return None
    }
}

struct Position {
    public init() {
        this(0, 0, 0)
    }
    public Position(private var _row: Int64, private var _col: Int64, private var _pos: Int64) {}

    public mut prop row: Int64 {
        get() {
            _row
        }
        set(v) {
            _row = v
        }
    }

    public mut prop col: Int64 {
        get() {
            _col
        }
        set(v) {
            _col = v
        }
    }

    public mut prop pos: Int64 {
        get() {
            _pos
        }
        set(v) {
            _pos = v
        }
    }
}

open class XmlException <: Exception {
    public init() {
        super()
    }
    public init(msg: String) {
        super(msg)
    }

    protected open override func getClassName(): String {
        return "XmlException"
    }
}

class XmlStatusException <: XmlException {
    public init() {
        super()
    }
    public init(msg: String) {
        super(msg)
    }

    protected override func getClassName(): String {
        return "XmlStatusException"
    }
}
