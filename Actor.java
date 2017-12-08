public class Actor {
	
	public Actor(String name, int mailbox_len) {
		this.name = name;
        this.mailbox_len = mailbox_len;
        this.actorSize = 0;
	}

	public String getName() {
		return name;
	}
	
	public int getCapacity() {
		return mailbox_len;
	}

	public int size() {
		return actorSize;
    }
    
    public void setSize(int size){
        actorSize = size;
    }

	@Override
	public String toString() {
		return String.format("Actor %s", name);
	}

	private String name;
    private int mailbox_len;
    private int actorSize;
}