/**
 * SymbolTableActorItemBase
 */
public abstract class SymbolTableActorItemBase extends SymbolTableItem{
    public SymbolTableActorItemBase(Actor actor, int offset) {
		this.actor = actor;
		this.offset = offset;
    }
    
    public int getSize() {
		return actor.size();
	}

	public int getOffset() {
		return offset;
	}

	public Actor getActor() {
		return actor;
    }
    
    @Override
	public String getKey() {
		return actor.getName();
    }
    
    public abstract Register getBaseRegister();

    Actor actor;
	int offset;
    
}